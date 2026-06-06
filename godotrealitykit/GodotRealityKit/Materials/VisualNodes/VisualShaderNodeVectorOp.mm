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
#include <godot_cpp/classes/visual_shader_node_vector_op.hpp>

#include <format>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeVectorOp)
	using OpType = godot::VisualShaderNodeVectorBase::OpType;
	using Operator = godot::VisualShaderNodeVectorOp::Operator;

	static const char* operator_names[Operator::OP_ENUM_SIZE] = { 0 };
	static const char* function_names[OpType::OP_TYPE_MAX][Operator::OP_ENUM_SIZE] = { 0 };

	INLET_COUNT(2)
	INPUT_TYPE_F(p_node_wrapper, p_index_param) {
		return gdrk::vs::to_port_type(UNWRAP()->get_op_type());
	}

	OUTPUT_TYPE_F(p_node_wrapper) {
		return gdrk::vs::to_port_type(UNWRAP()->get_op_type());
	}

	STATIC_INIT({
		function_names[OpType::OP_TYPE_VECTOR_2D][Operator::OP_ADD] = "ND_add_vector2";
		function_names[OpType::OP_TYPE_VECTOR_2D][Operator::OP_SUB] = "ND_subtract_vector2";
		function_names[OpType::OP_TYPE_VECTOR_2D][Operator::OP_MUL] = "ND_multiply_vector2";
		function_names[OpType::OP_TYPE_VECTOR_2D][Operator::OP_DIV] = "ND_divide_vector2";
		function_names[OpType::OP_TYPE_VECTOR_2D][Operator::OP_MOD] = "ND_modulo_vector2";
		function_names[OpType::OP_TYPE_VECTOR_2D][Operator::OP_POW] = "ND_power_vector2";
		function_names[OpType::OP_TYPE_VECTOR_2D][Operator::OP_MAX] = "ND_max_vector2";
		function_names[OpType::OP_TYPE_VECTOR_2D][Operator::OP_MIN] = "ND_min_vector2";
		function_names[OpType::OP_TYPE_VECTOR_2D][Operator::OP_CROSS] = nullptr; // Invalid operation
		function_names[OpType::OP_TYPE_VECTOR_2D][Operator::OP_ATAN2] = "ND_atan2_vector2";
		function_names[OpType::OP_TYPE_VECTOR_2D][Operator::OP_REFLECT] = "VisualShaderNodeVectorOp_reflect_vec2";
		function_names[OpType::OP_TYPE_VECTOR_2D][Operator::OP_STEP] = "ND_realitykit_step_vector2";
		
		function_names[OpType::OP_TYPE_VECTOR_3D][Operator::OP_ADD] = "ND_add_vector3";
		function_names[OpType::OP_TYPE_VECTOR_3D][Operator::OP_SUB] = "ND_subtract_vector3";
		function_names[OpType::OP_TYPE_VECTOR_3D][Operator::OP_MUL] = "ND_multiply_vector3";
		function_names[OpType::OP_TYPE_VECTOR_3D][Operator::OP_DIV] = "ND_divide_vector3";
		function_names[OpType::OP_TYPE_VECTOR_3D][Operator::OP_MOD] = "ND_modulo_vector3";
		function_names[OpType::OP_TYPE_VECTOR_3D][Operator::OP_POW] = "ND_power_vector3";
		function_names[OpType::OP_TYPE_VECTOR_3D][Operator::OP_MAX] = "ND_max_vector3";
		function_names[OpType::OP_TYPE_VECTOR_3D][Operator::OP_MIN] = "ND_min_vector3";
		function_names[OpType::OP_TYPE_VECTOR_3D][Operator::OP_CROSS] = "ND_crossproduct_vector3";
		function_names[OpType::OP_TYPE_VECTOR_3D][Operator::OP_ATAN2] = "ND_atan2_vector3";
		function_names[OpType::OP_TYPE_VECTOR_3D][Operator::OP_REFLECT] = "ND_realitykit_reflect_vector3";
		function_names[OpType::OP_TYPE_VECTOR_3D][Operator::OP_STEP] = "ND_realitykit_step_vector3";
		
		function_names[OpType::OP_TYPE_VECTOR_4D][Operator::OP_ADD] = "ND_add_vector4";
		function_names[OpType::OP_TYPE_VECTOR_4D][Operator::OP_SUB] = "ND_subtract_vector4";
		function_names[OpType::OP_TYPE_VECTOR_4D][Operator::OP_MUL] = "ND_multiply_vector4";
		function_names[OpType::OP_TYPE_VECTOR_4D][Operator::OP_DIV] = "ND_divide_vector4";
		function_names[OpType::OP_TYPE_VECTOR_4D][Operator::OP_MOD] = "ND_modulo_vector4";
		function_names[OpType::OP_TYPE_VECTOR_4D][Operator::OP_POW] = "ND_power_vector4";
		function_names[OpType::OP_TYPE_VECTOR_4D][Operator::OP_MAX] = "ND_max_vector4";
		function_names[OpType::OP_TYPE_VECTOR_4D][Operator::OP_MIN] = "ND_min_vector4";
		function_names[OpType::OP_TYPE_VECTOR_4D][Operator::OP_CROSS] = nullptr; // Invalid operation
		function_names[OpType::OP_TYPE_VECTOR_4D][Operator::OP_ATAN2] = "ND_atan2_vector4";
		function_names[OpType::OP_TYPE_VECTOR_4D][Operator::OP_REFLECT] = "VisualShaderNodeVectorOp_reflect_vec4";
		function_names[OpType::OP_TYPE_VECTOR_4D][Operator::OP_STEP] = "ND_realitykit_step_vector4";
		
		operator_names[Operator::OP_ADD] = "Add";
		operator_names[Operator::OP_SUB] = "Subtract";
		operator_names[Operator::OP_MUL] = "Multiply";
		operator_names[Operator::OP_DIV] = "Divide";
		operator_names[Operator::OP_MOD] = "Remainder";
		operator_names[Operator::OP_POW] = "Power";
		operator_names[Operator::OP_MAX] = "Max";
		operator_names[Operator::OP_MIN] = "Min";
		operator_names[Operator::OP_CROSS] = "Cross";
		operator_names[Operator::OP_ATAN2] = "ATan2";
		operator_names[Operator::OP_REFLECT] = "Reflect";
		operator_names[Operator::OP_STEP] = "Step";
	});

	DECLARATION(shader_type, p_context) {
		p_context.code_parts.push_back(R"""(
  
  let VisualShaderNodeVectorOp_reflect_vec2 = { (i, n) in
	let nn = ND_normalize_vector2(n);
	let dotnni2 = ND_multiply_float(ND_dotproduct_vector2(nn, i), 2.0f);
	ND_subtract_vector2(i, ND_multiply_vector2FA(nn, dotnni2))
  };
  let VisualShaderNodeVectorOp_reflect_vec4 = { (i, n) in
	  let nn = ND_normalize_vector4(n);
	  let dotnni2 = ND_multiply_float(ND_dotproduct_vector4(nn, i), 2.0f);
	  ND_subtract_vector4(i, ND_multiply_vector4FA(nn, dotnni2))
  };
  
		)""");
	}

	EXPRESSION(p_context, p_node_wrapper) {
		OpType op_type = UNWRAP()->get_op_type();
		Operator op = UNWRAP()->get_operator();
		
		const char* function_name = function_names[op_type][op];
		if (op > Operator::OP_ENUM_SIZE) {
			p_context.errors.push_back(std::format("VisualShaderNodeVectorOp: Unknown operator with identifier {}", (uint32_t) op));
			return;
		}
		
		if (op_type > OpType::OP_TYPE_MAX) {
			p_context.errors.push_back(std::format("VisualShaderNodeVectorOp: Unknown type {} for operator {}", (uint32_t) op_type, operator_names[op]));
			return;
		}
		
		if (!function_name) {
			// TODO (test needed):  ([GDRK] Any error in material conversion should result in a broken material being displayed)
			const char *type_name = port_type_name(gdrk::vs::to_port_type(UNWRAP()->get_op_type()));
			const char* operator_name = operator_names[op];
			p_context.errors.push_back(std::format("VisualShaderNodeVectorOp: Undefined operator {} for type {}", operator_name, type_name));
			return;
		}
		
		OUTPUT_EXPRESSION(0, std::format("{}({}, {})", function_name, INPUT_EXPRESSION(0), INPUT_EXPRESSION(1)));
	}
END(VisualShaderNodeVectorOp)
