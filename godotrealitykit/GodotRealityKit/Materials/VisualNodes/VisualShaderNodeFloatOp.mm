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
#include <godot_cpp/classes/visual_shader_node_float_op.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeFloatOp)
	INLET_COUNT(2)
	OUTPUT_TYPE(PortType::FLOAT)
	INPUT_TYPE(PortType::FLOAT)

	using Operator = godot::VisualShaderNodeFloatOp::Operator;
	static const char* function_names[Operator::OP_ENUM_SIZE];
	STATIC_INIT({
		function_names[Operator::OP_ADD] = "ND_add_float";
		function_names[Operator::OP_SUB] = "ND_subtract_float";
		function_names[Operator::OP_MUL] = "ND_multiply_float";
		function_names[Operator::OP_DIV] = "ND_divide_float";
		function_names[Operator::OP_MOD] = "ND_modulo_float";
		function_names[Operator::OP_POW] = "ND_power_float";
		function_names[Operator::OP_MAX] = "ND_max_float";
		function_names[Operator::OP_MIN] = "ND_min_float";
		function_names[Operator::OP_ATAN2] = "ND_atan2_float";
		function_names[Operator::OP_STEP] = "ND_realitykit_step_float";
	})

	EXPRESSION(p_context, p_node_wrapper) {
		godot::VisualShaderNodeFloatOp *node = (godot::VisualShaderNodeFloatOp *) p_node_wrapper.node;
		Operator op = node->get_operator();

		
		if (op > Operator::OP_ENUM_SIZE) {
			p_context.errors.push_back(std::format("godot::VisualShaderNodeFloatOp: Unknown operator: {}", (uint32_t) op));
			return;
		}
		
		const char* function_name = function_names[op];
		if (!function_name) {
			p_context.errors.push_back(std::format("godot::VisualShaderNodeFloatOp: Unsupported operator: {}", (uint32_t) op));
			return;
		}
		
		OUTPUT_EXPRESSION(0, std::format("{}({}, {})", function_name, INPUT_EXPRESSION(0), INPUT_EXPRESSION(1)));
	}
END(VisualShaderNodeFloatOp)
