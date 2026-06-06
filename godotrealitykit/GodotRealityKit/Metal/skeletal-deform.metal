//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc.
//
// Licensed under the MIT license (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// LICENSE
//
//===----------------------------------------------------------------------===//

#include <metal_stdlib>
using namespace metal;

#include "skeletal-deform.h"
#include "vertex-decode.h"

constant bool has_normal [[function_constant(0)]];
constant bool has_tangent [[function_constant(1)]];
constant bool has_skinning [[function_constant(2)]];
constant bool normalized_blend_shapes [[function_constant(3)]];
constant bool is_compressed [[function_constant(4)]];

constant float BLEND_SHAPE_WEIGHT_EPSILON = 0.0001;

// ---------------------------------------------------------------------------
// Helpers for reading the UNcompressed base_vertex_mtl format (UNORM 16-bit oct).

float2 unorm2x16_unpack(uint p) {
	ushort2 u = as_type<ushort2>(p);
	return float2(u) / 65535.0;
}

float2 weights_unorm2x16_unpack(uint p) {
	ushort2 u = as_type<ushort2>(p);
	return float2(u) / 65535.0;
}

float3 decode_normal(uint packed) {
	float2 unorm = unorm2x16_unpack(packed);
	return oct_to_vec3(unorm * 2.0 - 1.0);
}

float3 decode_tangent(uint packed, thread float &r_sign) {
	float2 unorm = unorm2x16_unpack(packed);
	float2 y_signed = float2(unorm.x, unorm.y * 2.0 - 1.0);
	r_sign = y_signed.y >= 0.0 ? 1.0 : -1.0;
	float2 oct = float2(y_signed.x * 2.0 - 1.0, abs(y_signed.y) * 2.0 - 1.0);
	return oct_to_vec3(oct);
}

// ---------------------------------------------------------------------------

float4x4 build_bone_matrix(device const float4 *bone_transforms, uint bone_idx) {
	return float4x4(
			bone_transforms[bone_idx],
			bone_transforms[bone_idx + 1],
			bone_transforms[bone_idx + 2],
			float4(0.0, 0.0, 0.0, 1.0));
}

kernel void skeletalDeform(
		device const uint32_t *src [[buffer(0)]],
		device uint32_t *dst [[buffer(1)]],
		device const uint32_t *skin_data [[buffer(2)]],
		device const float4 *bone_transforms [[buffer(3)]],
		constant SkinningParams &params [[buffer(4)]],
		device const uint32_t *blend_shape_data [[buffer(5)]],
		device const float *blend_shape_weights [[buffer(6)]],
		uint gid [[thread_position_in_grid]]) {
	if (gid >= params.vertex_count) {
		return;
	}

	uint vtx_stride_u32 = params.vertex_stride / 4;
	uint vtx_offset = gid * vtx_stride_u32;
	uint nt_stride_u32 = params.normal_tangent_stride / 4;
	uint nt_offset = params.normal_tangent_offset / 4 + gid * nt_stride_u32;

	uint dst_vtx_stride_u32 = is_compressed ? 3u : vtx_stride_u32;
	uint dst_vtx_offset = is_compressed ? gid * 3u : vtx_offset;
	uint dst_nt_stride_u32 = is_compressed ? ((has_normal || has_tangent) ? 2u : 0u) : nt_stride_u32;
	uint dst_nt_offset = is_compressed
			? params.vertex_count * 3u + gid * dst_nt_stride_u32
			: nt_offset;

	if (!is_compressed) {
		for (uint i = 0; i < vtx_stride_u32; i++) {
			dst[dst_vtx_offset + i] = src[vtx_offset + i];
		}
		for (uint i = 0; i < nt_stride_u32; i++) {
			dst[dst_nt_offset + i] = src[nt_offset + i];
		}
	}

	// ---------------------------------------------------------------------------
	// Decode position and normal/tangent.

	float3 pos;
	float3 normal = float3(0.0);
	float tangent_sign = 1.0;
	float3 tangent = float3(0.0);

	if (is_compressed) {
		device const ushort *cv = (device const ushort *)(src + vtx_offset);
		device const ushort *cnt = (device const ushort *)(src + nt_offset);
		decode_compressed_vertex(cv, cnt,
				float3(params.aabb_min[0], params.aabb_min[1], params.aabb_min[2]),
				float3(params.aabb_size[0], params.aabb_size[1], params.aabb_size[2]),
				has_normal || has_tangent,
				pos, normal, tangent, tangent_sign);
		if (!has_normal) {
			normal = float3(0.0);
		}
		if (!has_tangent) {
			tangent = float3(0.0);
		}
	} else {
		pos = float3(as_type<float>(src[vtx_offset + 0]),
				as_type<float>(src[vtx_offset + 1]),
				as_type<float>(src[vtx_offset + 2]));
		normal = has_normal ? decode_normal(src[nt_offset]) : float3(0.0);
		tangent = has_tangent ? decode_tangent(src[nt_offset + (has_normal ? 1u : 0u)], tangent_sign) : float3(0.0);
	}

	// ---------------------------------------------------------------------------
	// Blend shapes (uncompressed input only).

	if (!is_compressed && params.blend_shape_count > 0) {
		float blend_total = 0.0;
		float3 blend_pos = float3(0.0);
		float3 blend_normal = float3(0.0);
		float3 blend_tangent = float3(0.0);

		uint shape_stride_u32 = params.vertex_count * (vtx_stride_u32 + nt_stride_u32);

		for (uint i = 0; i < params.blend_shape_count; i++) {
			float w = blend_shape_weights[i];
			if (abs(w) <= BLEND_SHAPE_WEIGHT_EPSILON) {
				continue;
			}

			uint shape_pos_offset = shape_stride_u32 * i + gid * vtx_stride_u32;
			blend_pos += w * float3(as_type<float>(blend_shape_data[shape_pos_offset + 0]), as_type<float>(blend_shape_data[shape_pos_offset + 1]), as_type<float>(blend_shape_data[shape_pos_offset + 2]));

			if (has_normal || has_tangent) {
				uint shape_nt_offset = shape_stride_u32 * i + params.vertex_count * vtx_stride_u32 + gid * nt_stride_u32;
				if (has_normal) {
					blend_normal += w * decode_normal(blend_shape_data[shape_nt_offset]);
					shape_nt_offset++;
				}
				if (has_tangent) {
					float dummy_sign = 1.0;
					blend_tangent += w * decode_tangent(blend_shape_data[shape_nt_offset], dummy_sign);
				}
			}
			blend_total += w;
		}

		if (normalized_blend_shapes && blend_total != 0.0) {
			float bw = 1.0 - blend_total;
			pos = bw * pos;
			normal = bw * normal;
			tangent = bw * tangent;
		}
		pos += blend_pos;
		if (has_normal) {
			normal = normalize(normal + blend_normal);
		}
		if (has_tangent) {
			tangent = normalize(tangent + blend_tangent);
		}
	}

	// ---------------------------------------------------------------------------
	// Skinning.

	if (has_skinning) {
		uint skin_offset = params.skin_stride * gid;
		uint2 bones_raw = uint2(skin_data[skin_offset], skin_data[skin_offset + 1]);
		uint4 bone_idx = uint4(bones_raw.x & 0xFFFF, bones_raw.x >> 16,
								 bones_raw.y & 0xFFFF, bones_raw.y >> 16) *
				3;

		uint wt_offset = skin_offset + params.skin_weight_offset;
		uint2 wt_raw = uint2(skin_data[wt_offset], skin_data[wt_offset + 1]);
		float4 weights = float4(weights_unorm2x16_unpack(wt_raw.x), weights_unorm2x16_unpack(wt_raw.y));

		float4x4 m = build_bone_matrix(bone_transforms, bone_idx.x) * weights.x;
		m += build_bone_matrix(bone_transforms, bone_idx.y) * weights.y;
		m += build_bone_matrix(bone_transforms, bone_idx.z) * weights.z;
		m += build_bone_matrix(bone_transforms, bone_idx.w) * weights.w;

		if (params.skin_weight_offset == 4) {
			uint2 bones2_raw = uint2(skin_data[skin_offset + 2], skin_data[skin_offset + 3]);
			uint4 bone_idx2 = uint4(bones2_raw.x & 0xFFFF, bones2_raw.x >> 16,
									  bones2_raw.y & 0xFFFF, bones2_raw.y >> 16) *
					3;

			uint wt2_offset = wt_offset + 2;
			uint2 wt2_raw = uint2(skin_data[wt2_offset], skin_data[wt2_offset + 1]);
			float4 weights2 = float4(weights_unorm2x16_unpack(wt2_raw.x), weights_unorm2x16_unpack(wt2_raw.y));

			m += build_bone_matrix(bone_transforms, bone_idx2.x) * weights2.x;
			m += build_bone_matrix(bone_transforms, bone_idx2.y) * weights2.y;
			m += build_bone_matrix(bone_transforms, bone_idx2.z) * weights2.z;
			m += build_bone_matrix(bone_transforms, bone_idx2.w) * weights2.w;
		}

		pos = (float4(pos, 1.0) * m).xyz;
		if (has_normal) {
			normal = normalize((float4(normal, 0.0) * m).xyz);
		}
		if (has_tangent) {
			tangent = normalize((float4(tangent, 0.0) * m).xyz);
		}
	}

	// ---------------------------------------------------------------------------
	// Write output.

	dst[dst_vtx_offset + 0] = as_type<uint>(pos.x);
	dst[dst_vtx_offset + 1] = as_type<uint>(pos.y);
	dst[dst_vtx_offset + 2] = as_type<uint>(pos.z);

	if (has_normal) {
		dst[dst_nt_offset] = encode_normal(normal);
	}
	if (has_tangent) {
		dst[dst_nt_offset + (has_normal ? 1u : 0u)] = encode_tangent(tangent, tangent_sign);
	}
}
