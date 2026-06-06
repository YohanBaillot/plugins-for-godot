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

#include <string>


#define ENGINE_ANISTROPY_DEFAULT 4

namespace godot {
class VisualShaderNodeTextureParameter;
}

namespace gdrk {

enum LODSelection : uint8_t {
	LOD_SELECTION_AUTO = 0,
	LOD_SELECTION_MANUAL,

	LOD_SELECTION_MAX,
};

class VisualShaderNodeWrapper;
std::string get_sampler_function(const VisualShaderNodeWrapper &p_node_wrapper, LODSelection p_lod_selection);

} //namespace gdrk
