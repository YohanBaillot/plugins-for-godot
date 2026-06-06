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

#include <godot_cpp/classes/visual_shader_node_int_func.hpp>

#include <format>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeIntFunc)
	INLET_COUNT(1)
	OUTPUT_TYPE(PortType::INT)
	INPUT_TYPE(PortType::INT)

	using Function = godot::VisualShaderNodeIntFunc::Function;
	static const char* function_names[Function::FUNC_MAX];
	static const char* op_names[Function::FUNC_MAX];
	STATIC_INIT({
			function_names[Function::FUNC_ABS] = "ND_MTL_abs_integer";
			function_names[Function::FUNC_NEGATE] = "VisualShaderNodeIntOp_sub";
			function_names[Function::FUNC_SIGN] = "VisualShaderNodeIntOp_sign";
			function_names[Function::FUNC_BITWISE_NOT] = nullptr;
		
			op_names[Function::FUNC_ABS] = "godot::VisualShaderNodeIntFunc::Function::FUNC_ABS";
			op_names[Function::FUNC_NEGATE] = "godot::VisualShaderNodeIntFunc::Function::FUNC_NEGATE";
			op_names[Function::FUNC_SIGN] = "godot::VisualShaderNodeIntFunc::Function::FUNC_SIGN";
			op_names[Function::FUNC_BITWISE_NOT] = "godot::VisualShaderNodeIntFunc::Function::FUNC_BITWISE_NOT";
	});

	ANALYZE(p_context, p_node_wrapper) {
		Function func = UNWRAP()->get_function();
		if (func > Function::FUNC_MAX) {
			p_context.errors.push_back(std::format("godot::VisualShaderNodeIntFunc: Unknown operator: {}", (uint32_t) func));
			return;
		}
		
		if (!function_names[func]) {
			p_context.errors.push_back(std::format("godot::VisualShaderNodeIntFunc: operation {} not supported", op_names[func]));
			return;
		}
	}

	DECLARATION(p_shader_type, p_context) {
		p_context.code_parts.push_back(R"""(
			let VisualShaderNodeIntOp_sub = { (v) in
				float_to_int(ND_multiply_integer(int_to_float(v), -1.0))
			};
			let VisualShaderNodeIntOp_sign = { (v) in
				float_to_int(ND_sign_float(int_to_float(v)))
			};
		)""");
	}

	EXPRESSION(p_context, p_node_wrapper) {
		const char* function_name = function_names[UNWRAP()->get_function()];
		OUTPUT_EXPRESSION(0, std::format("{}({})", function_name, INPUT_EXPRESSION(0)));
	}
END(VisualShaderNodeIntFunc)
