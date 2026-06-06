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
#include <godot_cpp/classes/visual_shader_node_boolean_constant.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeBooleanConstant)
	INLET_COUNT(0)
	OUTPUT_TYPE(PortType::BOOL)

	EXPRESSION(p_context, p_node_wrapper) {
		godot::VisualShaderNodeBooleanConstant *node = (godot::VisualShaderNodeBooleanConstant *)p_node_wrapper.node;
		bool val = node->get_constant();
		std::string let = sgl::statement::let(p_node_wrapper.get_output_var_name(p_context, 0), sgl::boolean::value(val));
		p_context.code_parts.push_back(let);
	}
END(VisualShaderNodeBooleanConstant)
