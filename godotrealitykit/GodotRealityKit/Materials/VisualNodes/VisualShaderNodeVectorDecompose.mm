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
#include <godot_cpp/classes/visual_shader_node_vector_decompose.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeVectorDecompose)
	using OpType = godot::VisualShaderNodeVectorBase::OpType;
	INLET_COUNT(1)
	GENERIC_VECTOR_INPUT_TYPE()

	OUTPUT_TYPE(PortType::FLOAT)

	ANALYZE(p_context, p_node_wrapper) {
		OpType op = UNWRAP()->get_op_type();
		if (op > OpType::OP_TYPE_MAX) {
			p_context.errors.push_back(std::format("VisualShaderNodeVectorDecompose: provided op value is invalid: {}", (uint32_t) op));
		}
	}

	EXPRESSION(p_context, p_node_wrapper) {
		OpType op = UNWRAP()->get_op_type();
		
		std::string input_expression = INPUT_EXPRESSION(0);
		if (op == OpType::OP_TYPE_VECTOR_2D) {
			OUTPUT_EXPRESSION(0, std::format("v2_x({})", input_expression));
			OUTPUT_EXPRESSION(1, std::format("v2_y({})", input_expression));
		} else if (op == OpType::OP_TYPE_VECTOR_3D) {
			OUTPUT_EXPRESSION(0, std::format("v3_x({})", input_expression));
			OUTPUT_EXPRESSION(1, std::format("v3_y({})", input_expression));
			OUTPUT_EXPRESSION(2, std::format("v3_z({})", input_expression));
		} else if (op == OpType::OP_TYPE_VECTOR_4D) {
			OUTPUT_EXPRESSION(0, std::format("v4_x({})", input_expression));
			OUTPUT_EXPRESSION(1, std::format("v4_y({})", input_expression));
			OUTPUT_EXPRESSION(2, std::format("v4_z({})", input_expression));
			OUTPUT_EXPRESSION(3, std::format("v4_w({})", input_expression));
		} else {
			p_context.errors.push_back(std::format("VisualShaderNodeVectorDecompose: Unknown operation: {}", (uint32_t) op));
		}
	}
END(VisualShaderNodeVectorDecompose)
