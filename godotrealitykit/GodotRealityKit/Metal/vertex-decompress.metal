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

#include "vertex-decode.h"

struct VertexDecompressParams {
	packed_float3 aabb_min;
	packed_float3 aabb_size;
	uint src_vertex_stride; // 8 for compressed (ushort4: pos.xyz + tangent_angle)
	uint src_nt_base; // byte offset of NT section in src buffer
	uint src_nt_stride; // 4 for compressed (ushort2 oct-encoded rotation axis)
	uint dst_nt_base; // vertex_count * 12 (positions are float3)
	uint has_tangents; // 0 or 1
};

// Decompresses one vertex from ARRAY_FLAG_COMPRESS_ATTRIBUTES format into the
// standard uncompressed layout (float3 pos + UNORM oct normal/tangent).
kernel void decompressVertices(
		device const uint8_t *src [[buffer(0)]],
		device uint8_t *dst [[buffer(1)]],
		constant VertexDecompressParams &p [[buffer(2)]],
		uint gid [[thread_position_in_grid]]) {
	device const ushort *v = (device const ushort *)(src + gid * p.src_vertex_stride);
	device const ushort *v_nt = (device const ushort *)(src + p.src_nt_base + gid * p.src_nt_stride);

	float3 pos, normal, tangent;
	float tangent_sign;
	decode_compressed_vertex(v, v_nt,
			float3(p.aabb_min), float3(p.aabb_size),
			/*decode_nt=*/true,
			pos, normal, tangent, tangent_sign);

	// Write float3 position.
	device float *dst_pos = (device float *)(dst + gid * 12);
	dst_pos[0] = pos.x;
	dst_pos[1] = pos.y;
	dst_pos[2] = pos.z;

	// Write UNORM oct normal (always present) and optional tangent.
	device uint *dst_nt = (device uint *)(dst + p.dst_nt_base + gid * 8);
	dst_nt[0] = encode_normal(normal);
	if (p.has_tangents) {
		dst_nt[1] = encode_tangent(tangent, tangent_sign);
	}
}
