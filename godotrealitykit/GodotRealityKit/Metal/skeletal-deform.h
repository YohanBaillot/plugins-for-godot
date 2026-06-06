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

#ifndef __METAL_VERSION__
#include <cstdint>
#endif

struct SkinningParams {
	uint32_t vertex_count;
	uint32_t vertex_stride; // bytes per vertex in position section
	uint32_t normal_tangent_offset; // byte offset of NT section from buffer start
	uint32_t normal_tangent_stride; // bytes per vertex in NT section
	uint32_t skin_stride; // stride per vertex in skin buffer, in uint32 units
	uint32_t skin_weight_offset; // offset from bone indices to weights, in uint32 units
	uint32_t blend_shape_count; // morph targets; 0 disables the blend-shape path

	// Used when is_compressed function constant is true: AABB for ushort→float dequantization.
	float aabb_min[3];
	float aabb_size[3];
};
