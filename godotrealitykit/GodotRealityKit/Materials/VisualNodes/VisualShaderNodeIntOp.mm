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

#include <godot_cpp/classes/visual_shader_node_int_op.hpp>

#include <format>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeIntOp)
	INLET_COUNT(2)
	OUTPUT_TYPE(PortType::INT)
	INPUT_TYPE(PortType::INT)

	using Operator = godot::VisualShaderNodeIntOp::Operator;
	static const char* function_names[Operator::OP_ENUM_SIZE];
	static const char* op_names[Operator::OP_ENUM_SIZE];
	STATIC_INIT({
			// FIXME:  ([GDRK] Finish implementation of VisualShaderNodeIntOp)
			function_names[Operator::OP_ADD] = "VisualShaderNodeIntOp_add_integer";
			function_names[Operator::OP_SUB] = "VisualShaderNodeIntOp_sub_integer";
		
	
			function_names[Operator::OP_MUL] = "VisualShaderNodeIntOp_multiply";
			function_names[Operator::OP_DIV] = "VisualShaderNodeIntOp_divide";
			function_names[Operator::OP_MOD] = "VisualShaderNodeIntOp_mod";
			function_names[Operator::OP_MAX] = "VisualShaderNodeIntOp_min";
			function_names[Operator::OP_MIN] = "VisualShaderNodeIntOp_max";
		
			function_names[Operator::OP_BITWISE_AND] = nullptr;
			function_names[Operator::OP_BITWISE_OR] = nullptr;
			function_names[Operator::OP_BITWISE_XOR] = nullptr;
			function_names[Operator::OP_BITWISE_LEFT_SHIFT] = nullptr;
			function_names[Operator::OP_BITWISE_RIGHT_SHIFT] = nullptr;
		
			op_names[Operator::OP_ADD] = "godot::VisualShaderNodeIntOp::Operator::OP_ADD";
			op_names[Operator::OP_SUB] = "godot::VisualShaderNodeIntOp::Operator::OP_SUB";
			op_names[Operator::OP_MUL] = "godot::VisualShaderNodeIntOp::Operator::OP_MUL";
			op_names[Operator::OP_DIV] = "godot::VisualShaderNodeIntOp::Operator::OP_DIV";
			op_names[Operator::OP_MOD] = "godot::VisualShaderNodeIntOp::Operator::OP_MOD";
			op_names[Operator::OP_MAX] = "godot::VisualShaderNodeIntOp::Operator::OP_MAX";
			op_names[Operator::OP_MIN] = "godot::VisualShaderNodeIntOp::Operator::OP_MIN";
			op_names[Operator::OP_BITWISE_AND] = "godot::VisualShaderNodeIntOp::Operator::OP_BITWISE_AND";
			op_names[Operator::OP_BITWISE_OR] = "godot::VisualShaderNodeIntOp::Operator::OP_BITWISE_OR";
			op_names[Operator::OP_BITWISE_XOR] = "godot::VisualShaderNodeIntOp::Operator::OP_BITWISE_XOR";
			op_names[Operator::OP_BITWISE_LEFT_SHIFT] = "godot::VisualShaderNodeIntOp::Operator::OP_BITWISE_LEFT_SHIFT";
			op_names[Operator::OP_BITWISE_RIGHT_SHIFT] = "godot::VisualShaderNodeIntOp::Operator::OP_BITWISE_RIGHT_SHIFT";
	});

	DECLARATION(p_shader_type, p_context) {
		
		// Consider changing all of those operations to native integer ops instead of performing float conversions
		static const char *functions = R"""(
			let VisualShaderNodeIntOp_add_integer = { (n1, n2) in
				let n1f = int_to_float(n1);
				let n2f = int_to_float(n2);
				let resf = ND_add_float(n1f, n2f);
				float_to_int(resf)
			};
			let VisualShaderNodeIntOp_sub_integer = { (n1, n2) in
				let n1f = int_to_float(n1);
				let n2f = int_to_float(n2);
				let resf = ND_subtract_float(n1f, n2f);
				float_to_int(resf)
			};
  
			let VisualShaderNodeIntOp_multiply = { (n1, n2) in
				let n1f = int_to_float(n1);
				let n2f = int_to_float(n2);
				let resf = ND_multiply_float(n1f, n2f);
				float_to_int(resf)
			};
			let VisualShaderNodeIntOp_divide = { (n1, n2) in
				let n1f = int_to_float(n1);
				let n2f = int_to_float(n2);
				let resf = ND_divide_float(n1f, n2f);
				float_to_int(resf)
			};
			let VisualShaderNodeIntOp_mod = { (n1, n2) in
				let n1f = int_to_float(n1);
				let n2f = int_to_float(n2);
				let resf = ND_modulo_float(n1f, n2f);
				float_to_int(resf)
			};
			let VisualShaderNodeIntOp_min = { (n1, n2) in
				let n1f = int_to_float(n1);
				let n2f = int_to_float(n2);
				let resf = ND_min_float(n1f, n2f);
				float_to_int(resf)
			};
			let VisualShaderNodeIntOp_max = { (n1, n2) in
				let n1f = int_to_float(n1);
				let n2f = int_to_float(n2);
				let resf = ND_max_float(n1f, n2f);
				float_to_int(resf)
			};
		)""";
		
		p_context.code_parts.push_back(functions);
		
	}

	ANALYZE(p_context, p_node_wrapper) {
		Operator op = UNWRAP()->get_operator();
		if (op > Operator::OP_ENUM_SIZE) {
			p_context.errors.push_back(std::format("godot::VisualShaderNodeIntOp: Unknown operator: {}", (uint32_t) op));
			return;
		}
		
		if (!function_names[op]) {
			p_context.errors.push_back(std::format("godot::VisualShaderNodeIntOp: operation {} not supported", op_names[op]));
			return;
		}
	}

	EXPRESSION(p_context, p_node_wrapper) {
		const char* function_name = function_names[UNWRAP()->get_operator()];
		OUTPUT_EXPRESSION(0, std::format("{}({}, {})", function_name, INPUT_EXPRESSION(0), INPUT_EXPRESSION(1)));
	}
END(VisualShaderNodeIntOp)
