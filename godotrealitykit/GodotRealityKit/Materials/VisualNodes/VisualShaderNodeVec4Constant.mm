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

#include "Supported.h"
#include <godot_cpp/classes/visual_shader_node_vec4_constant.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeVec4Constant)
	INLET_COUNT(0)
	OUTPUT_TYPE(PortType::VEC4F)

	EXPRESSION(p_context, p_node_wrapper) {
		godot::Quaternion value = UNWRAP()->get_constant();
		OUTPUT_EXPRESSION(0, sgl::vec4::quaternion(value));
	}
END(VisualShaderNodeVec4Constant)
