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

#pragma once

#include <metal_stdlib>
using namespace metal;

// ---------------------------------------------------------------------------
// Octahedral helpers

// Decode: SNORM [-1,1] → normalised float3.
static float3 oct_to_vec3(float2 oct_snorm) {
	float3 n = float3(oct_snorm.x, oct_snorm.y, 1.0 - abs(oct_snorm.x) - abs(oct_snorm.y));
	float t = clamp(-n.z, 0.0, 1.0);
	n.x += n.x >= 0.0 ? -t : t;
	n.y += n.y >= 0.0 ? -t : t;
	return normalize(n);
}

// Encode: float3 → SNORM [-1,1].
static float2 vec3_to_oct(float3 n) {
	n /= (abs(n.x) + abs(n.y) + abs(n.z));
	if (n.z >= 0.0) {
		return n.xy;
	}
	return float2(
			(1.0 - abs(n.y)) * (n.x >= 0.0 ? 1.0 : -1.0),
			(1.0 - abs(n.x)) * (n.y >= 0.0 ? 1.0 : -1.0));
}

// ---------------------------------------------------------------------------
// UNORM packing

static uint unorm2x16_pack(float2 v) {
	ushort2 u = ushort2(
			ushort(clamp(v.x * 65535.0, 0.0, 65535.0)),
			ushort(clamp(v.y * 65535.0, 0.0, 65535.0)));
	return as_type<uint>(u);
}

// Encode float3 normal → Godot UNORM oct (packed uint32).
static uint encode_normal(float3 n) {
	float2 oct = vec3_to_oct(n);
	return unorm2x16_pack(oct * 0.5 + 0.5);
}

// Encode float3 tangent + bitangent sign → Godot UNORM oct (packed uint32).
static uint encode_tangent(float3 tangent, float sign_val) {
	float2 oct = vec3_to_oct(tangent);
	float2 unorm = oct * 0.5 + 0.5;
	unorm.y = max(unorm.y, 1.0 / 32767.0);
	unorm.y = unorm.y * 0.5 + 0.5;
	unorm.y = sign_val >= 0.0 ? unorm.y : 1.0 - unorm.y;
	return unorm2x16_pack(unorm);
}

// ---------------------------------------------------------------------------
// Decode axis+angle → TBN rows.
// tangent = rows[0], binormal = rows[1], normal = rows[2].

static void axis_angle_to_tbn(float3 axis, float angle,
		thread float3 &tangent, thread float3 &binormal, thread float3 &normal) {
	float c = cos(angle);
	float s = sin(angle);
	float3 omc = (1.0f - c) * axis;
	float3 sa = s * axis;
	tangent = omc.xxx * axis + float3(c, -sa.z, sa.y);
	binormal = omc.yyy * axis + float3(sa.z, c, -sa.x);
	normal = omc.zzz * axis + float3(-sa.y, sa.x, c);
}

// ---------------------------------------------------------------------------
// Full compressed-vertex decode (ARRAY_FLAG_COMPRESS_ATTRIBUTES format).
//   p_vertex : ushort4  — pos_x, pos_y, pos_z, tangent_angle
//   p_nt     : ushort2  — oct-encoded TBN rotation axis
//   decode_nt: whether p_nt is valid and should be decoded
// Outputs positions dequantised by AABB; normal / tangent / tangent_sign only
// written when decode_nt is true.

static void decode_compressed_vertex(
		device const ushort *p_vertex,
		device const ushort *p_nt,
		float3 aabb_min, float3 aabb_size,
		bool decode_nt,
		thread float3 &out_pos,
		thread float3 &out_normal,
		thread float3 &out_tangent,
		thread float &out_tangent_sign) {
	float3 pos_norm = float3(p_vertex[0], p_vertex[1], p_vertex[2]) / 65535.0f;
	out_pos = aabb_min + pos_norm * aabb_size;

	if (decode_nt) {
		float angle_norm = float(p_vertex[3]) / 65535.0f;
		float bin_sign = angle_norm > 0.5f ? 1.0f : -1.0f;
		float angle = abs(angle_norm * 2.0f - 1.0f) * M_PI_F;

		float2 oct_axis = float2(p_nt[0], p_nt[1]) / 65535.0f;
		float3 axis = oct_to_vec3(oct_axis * 2.0f - 1.0f);

		float3 tang, binorm, norm;
		axis_angle_to_tbn(axis, angle, tang, binorm, norm);
		binorm *= bin_sign;

		out_normal = norm;
		out_tangent = tang;
		out_tangent_sign = bin_sign;
	}
}
