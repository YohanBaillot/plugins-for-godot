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

#include "TextureSampler.h"
#include "../visual_shader_node_wrapper.h"

using namespace gdrk;

std::string gdrk::get_sampler_function(const VisualShaderNodeWrapper &p_node_wrapper,
		LODSelection p_lod_selection) {
	const char *selection_suffix = p_lod_selection == LODSelection::LOD_SELECTION_AUTO ? "auto_lod" : "manual_lod";
	return std::format("{}_sample_{}", p_node_wrapper.var_name, selection_suffix);
}
