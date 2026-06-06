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
#include <godot_cpp/classes/visual_shader_node_vector_func.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeVectorFunc)
	using OpType = godot::VisualShaderNodeVectorBase::OpType;
	INLET_COUNT(1)
	GENERIC_VECTOR_OUTPUT_TYPE();
	GENERIC_VECTOR_INPUT_TYPE();

	using Function = godot::VisualShaderNodeVectorFunc::Function;
	static const char* function_names[OpType::OP_TYPE_MAX][Function::FUNC_MAX];

#define  DEFINE_FUNC_FOR_ALL_TYPES(type, func_prefix) \
				function_names[OpType::OP_TYPE_VECTOR_2D][Function::type] = func_prefix "_vector2"; \
				function_names[OpType::OP_TYPE_VECTOR_3D][Function::type] = func_prefix "_vector3"; \
				function_names[OpType::OP_TYPE_VECTOR_4D][Function::type] = func_prefix "_vector4";

	STATIC_INIT({
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_NORMALIZE, "ND_normalize");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_SATURATE, "VisualShaderNodeVectorFunc_saturate");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_NEGATE, "VisualShaderNodeVectorFunc_negate");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_RECIPROCAL, "VisualShaderNodeVectorFunc_reciprocal");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_ABS, "ND_absval");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_ACOS, "ND_acos");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_ACOSH, "ND_MTL_acosh");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_ASIN, "ND_asin");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_ASINH, "ND_MTL_asinh");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_ATAN, "ND_MTL_atan");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_ATANH, "ND_MTL_atanh");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_CEIL, "ND_ceil");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_COS, "ND_cos");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_COSH, "ND_MTL_cosh");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_DEGREES, "VisualShaderNodeVectorFunc_degrees");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_EXP, "ND_exp");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_EXP2, "ND_MTL_exp2");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_FLOOR, "ND_floor");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_FRACT, "ND_realitykit_fractional");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_INVERSE_SQRT, "ND_MTL_rsqrt");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_LOG, "ND_MTL_log10");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_LOG2, "ND_MTL_log2");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_RADIANS, "VisualShaderNodeVectorFunc_radians");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_ROUND, "ND_round");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_ROUNDEVEN, "VisualShaderNodeVectorFunc_roundeven");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_SIGN, "ND_sign");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_SIN, "ND_sin");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_SINH, "ND_MTL_sinh");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_SQRT, "ND_sqrt");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_TAN, "ND_tan");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_TANH, "ND_MTL_tanh");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_TRUNC, "ND_trunc");
		DEFINE_FUNC_FOR_ALL_TYPES(FUNC_ONEMINUS, "ND_realitykit_oneminus");
	});

	DECLARATION(p_shader_type, p_context) {
		p_context.code_parts.push_back(R"""(
			let VisualShaderNodeVectorFunc_saturate_vector2 = { (v) in ND_clamp_vector2FA(v, 0.0f, 1.0f) }
			let VisualShaderNodeVectorFunc_negate_vector2 = { (v) in ND_multiply_vector2FAt(v, -1.0f) }
			let VisualShaderNodeVectorFunc_degrees_vector2 = { (v) in ND_multiply_vector2FA(v, 57.29577951308232f) }
			let VisualShaderNodeVectorFunc_radians_vector2 = { (v) in ND_multiply_vector2FA(v, 0.017453292519943295f) }
			let VisualShaderNodeVectorFunc_reciprocal_vector2 = { (v) in ND_divide_vector2((1.0f, 1.0f), v) }
			let VisualShaderNodeVectorFunc_roundeven_vector2 = { (v) in ND_round_vector2(ND_multiply_vector2FA(v, 0.5f)) }
  
			let VisualShaderNodeVectorFunc_saturate_vector3 = { (v) in ND_clamp_vector3FA(v, 0.0f, 1.0f) }
			let VisualShaderNodeVectorFunc_negate_vector3 = { (v) in ND_multiply_vector3FAt(v, -1.0f) }
			let VisualShaderNodeVectorFunc_degrees_vector3 = { (v) in ND_multiply_vector3FA(v, 57.29577951308232f) }
			let VisualShaderNodeVectorFunc_radians_vector3 = { (v) in ND_multiply_vector3FA(v, 0.017453292519943295f) }
			let VisualShaderNodeVectorFunc_reciprocal_vector3 = { (v) in ND_divide_vector3((1.0f, 1.0f, 1.0f), v) }
			let VisualShaderNodeVectorFunc_roundeven_vector3 = { (v) in ND_round_vector3(ND_multiply_vector3FA(v, 0.5f)) }

			let VisualShaderNodeVectorFunc_saturate_vector4 = { (v) in ND_clamp_vector4FA(v, 0.0f, 1.0f) }
			let VisualShaderNodeVectorFunc_negate_vector4 = { (v) in ND_multiply_vector4FAt(v, -1.0f) }
			let VisualShaderNodeVectorFunc_degrees_vector4 = { (v) in ND_multiply_vector4FA(v, 57.29577951308232f) }
			let VisualShaderNodeVectorFunc_radians_vector4 = { (v) in ND_multiply_vector4FA(v, 0.017453292519943295f) }
			let VisualShaderNodeVectorFunc_reciprocal_vector4 = { (v) in ND_divide_vector4((1.0f, 1.0f, 1.0f, 1.0f), v) }
			let VisualShaderNodeVectorFunc_roundeven_vector4 = { (v) in ND_round_vector4(ND_multiply_vector4FA(v, 0.5f)) }
		)""");
	}

	ANALYZE(p_context, p_node_wrapper) {
		OpType op = UNWRAP()->get_op_type();
		if (op > OpType::OP_TYPE_MAX) {
			p_context.errors.push_back(std::format("VisualShaderNodeVectorDecompose: provided op value is invalid: {}", (uint32_t) op));
		}
		
		Function func = UNWRAP()->get_function();
		if (func > Function::FUNC_MAX) {
			p_context.errors.push_back(std::format("godot::VisualShaderNodeVectorFunc: Unknown operator: {}", (uint32_t) func));
		}
	}

	EXPRESSION(p_context, p_node_wrapper) {
		Function func = UNWRAP()->get_function();
		OpType opType = UNWRAP()->get_op_type();
		const char* function_name = function_names[opType][func];
		OUTPUT_EXPRESSION(0, std::format("{}({})", function_name, INPUT_EXPRESSION(0)));
	}
END(VisualShaderNodeVectorFunc)
