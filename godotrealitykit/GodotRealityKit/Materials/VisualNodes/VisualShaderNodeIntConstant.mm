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

#include "../visual_program_builder.h"
#include "../visual_shader_node_wrapper.h"
#include "snippets.h"

#include <godot_cpp/classes/visual_shader_node_int_constant.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeIntConstant)
	INLET_COUNT(0)
	OUTPUT_TYPE(PortType::INT)

	EXPRESSION(p_context, p_node_wrapper) {
		int value = UNWRAP()->get_constant();
		OUTPUT_EXPRESSION(0, sgl::number::value(value));
	}
END(VisualShaderNodeIntConstant)
