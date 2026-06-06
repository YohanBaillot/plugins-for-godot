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
#include "VisualShaderNodeVectorBase.h"
#include <godot_cpp/classes/visual_shader_node_vector_compose.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeVectorCompose)
	using OpType = godot::VisualShaderNodeVectorBase::OpType;
	INLET_COUNT(4)
	INPUT_TYPE(PortType::FLOAT)
	GENERIC_VECTOR_OUTPUT_TYPE()

	EXPRESSION(p_context, p_node_wrapper) {
		OpType op = UNWRAP()->get_op_type();
		if (op == OpType::OP_TYPE_VECTOR_2D) {
			OUTPUT_EXPRESSION(0, std::format("ND_combine2_vector2({}, {})", INPUT_EXPRESSION(0), INPUT_EXPRESSION(1)));
		} else if (op == OpType::OP_TYPE_VECTOR_3D) {
			OUTPUT_EXPRESSION(0, std::format("ND_combine3_vector3({}, {}, {})", INPUT_EXPRESSION(0), INPUT_EXPRESSION(1), INPUT_EXPRESSION(2)));
		} else if (op == OpType::OP_TYPE_VECTOR_4D) {
			OUTPUT_EXPRESSION(0, std::format("ND_combine4_vector4({}, {}, {}, {})", INPUT_EXPRESSION(0), INPUT_EXPRESSION(1), INPUT_EXPRESSION(2), INPUT_EXPRESSION(3)));
		} else {
			p_context.errors.push_back(std::format("VisualShaderNodeVectorCompose: Unknown operation: {}", (uint32_t) op));
		}
	}
END(VisualShaderNodeVectorCompose)
