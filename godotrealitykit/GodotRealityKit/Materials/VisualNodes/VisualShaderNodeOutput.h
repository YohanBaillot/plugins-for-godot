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

#include <cstdint>

namespace gdrk {
namespace vs {

enum FragmentOutput : uint8_t {
	FO_ALBEDO = 0,
	FO_ALPHA,
	FO_METALLIC,
	FO_ROUGHNESS,
	FO_SPECULAR,
	FO_EMISSION,
	FO_AO,
	FO_AO_LIGHT_EFFECT,
	FO_NORMAL,
	FO_NORMAL_MAP,
	FO_NORMAL_MAP_DEPTH,

	FO_RIM,
	FO_RIM_TINT,
	FO_CLEAR_COAT,
	FO_CLEAR_COAT_ROUGHNESS,
	FO_ANISOTROPY,
	FO_ANISOTROPY_FLOW,
	FO_SUBSRUFACE_SCATTER,
	FO_BACKLIGHT,
	FO_ALPHA_SCISSOR_THRESHOLD,
	FO_ALPHA_HASH_SCALE,
	FO_ALPHA_AA_EDGE,
	FO_ALPHA_UV,
	FO_DEPTH,
	FO_BENT_NORMAL_MAP,

	FO_COUNT,
};

enum VertexOutput : uint8_t {
	VO_POSITION = 0,
	VO_NORMAL,

	VO_TANGENT,
	VO_BINORMAL,
	VO_UV,
	VO_UV2,
	VO_COLOR,

	VO_ALPHA,
	VO_COUNT,

	// TODO
	VO_ROUGHNESS,
	VO_POINT_SIZE,
	VO_MODEL_VIEW_MATRIX,
	VO_PROJECTION_MATRIX,

};

} // namespace vs
} // namespace gdrk
