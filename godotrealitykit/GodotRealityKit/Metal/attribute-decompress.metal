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

struct AttributeDecompressParams {
	uint src_attr_stride;
	uint src_color_offset;
	uint src_uv1_offset;
	uint src_uv2_offset;
	uint dst_attr_stride;
	uint dst_color_offset;
	uint dst_uv1_offset;
	uint dst_uv2_offset;
	uint has_color;
	uint has_uv1;
	uint has_uv2;
	uint pad;
};

// Converts ushort2-normalized UVs to float2 in [0,1] and copies color verbatim.
// The material shader continues to apply uv_scale via (uv - 0.5) * uv_scale.xy.
kernel void decompressAttributes(
		device const uint8_t *src [[buffer(0)]],
		device uint8_t *dst [[buffer(1)]],
		constant AttributeDecompressParams &p [[buffer(2)]],
		uint gid [[thread_position_in_grid]]) {
	if (p.has_color) {
		device const uint32_t *src_c = (device const uint32_t *)(src + gid * p.src_attr_stride + p.src_color_offset);
		device uint32_t *dst_c = (device uint32_t *)(dst + gid * p.dst_attr_stride + p.dst_color_offset);
		*dst_c = *src_c;
	}

	if (p.has_uv1) {
		device const ushort *src_uv = (device const ushort *)(src + gid * p.src_attr_stride + p.src_uv1_offset);
		device float *dst_uv = (device float *)(dst + gid * p.dst_attr_stride + p.dst_uv1_offset);
		dst_uv[0] = float(src_uv[0]) / 65535.0f;
		dst_uv[1] = float(src_uv[1]) / 65535.0f;
	}

	if (p.has_uv2) {
		device const ushort *src_uv = (device const ushort *)(src + gid * p.src_attr_stride + p.src_uv2_offset);
		device float *dst_uv = (device float *)(dst + gid * p.dst_attr_stride + p.dst_uv2_offset);
		dst_uv[0] = float(src_uv[0]) / 65535.0f;
		dst_uv[1] = float(src_uv[1]) / 65535.0f;
	}
}
