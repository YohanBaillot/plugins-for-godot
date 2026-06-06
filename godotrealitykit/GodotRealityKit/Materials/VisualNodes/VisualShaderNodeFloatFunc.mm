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
#include <godot_cpp/classes/visual_shader_node_float_func.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeFloatFunc)
	INLET_COUNT(2)
	OUTPUT_TYPE(PortType::FLOAT)
	INPUT_TYPE(PortType::FLOAT)

	using Function = godot::VisualShaderNodeFloatFunc::Function;
	static const char* function_names[Function::FUNC_MAX];
	STATIC_INIT({
		function_names[Function::FUNC_SIN] = "ND_sin_float";
		function_names[Function::FUNC_COS] = "ND_cos_float";
		function_names[Function::FUNC_TAN] = "ND_tan_float";
		function_names[Function::FUNC_ASIN] = "ND_asin_float";
		function_names[Function::FUNC_ACOS] = "ND_acos_float";
		function_names[Function::FUNC_ATAN] = "ND_atan_float";
		function_names[Function::FUNC_SINH] = "ND_MTL_sinh_float";
		function_names[Function::FUNC_COSH] = "ND_MTL_cosh_float";
		function_names[Function::FUNC_TANH] = "ND_MTL_tanh_float";
		function_names[Function::FUNC_LOG] = "ND_MTL_log10_float";
		function_names[Function::FUNC_EXP] = "ND_MTL_exp10_float";
		function_names[Function::FUNC_SQRT] = "ND_sqrt_float";
		function_names[Function::FUNC_ABS] = "ND_absval_float";
		function_names[Function::FUNC_SIGN] = "ND_sign_float";
		function_names[Function::FUNC_FLOOR] = "ND_floor_float";
		function_names[Function::FUNC_ROUND] = "ND_round_float";
		function_names[Function::FUNC_CEIL] = "ND_ceil_float";
		function_names[Function::FUNC_FRACT] = "ND_realitykit_fractional";
		function_names[Function::FUNC_SATURATE] = "VisualShaderNodeFloatFunc_saturate";
		function_names[Function::FUNC_NEGATE] = "VisualShaderNodeFloatFunc_negate";
		function_names[Function::FUNC_ACOSH] = "ND_MTL_acosh_float";
		function_names[Function::FUNC_ASINH] = "ND_MTL_asinh_float";
		function_names[Function::FUNC_ATANH] = "ND_MTL_atanh_float";
		function_names[Function::FUNC_DEGREES] = "VisualShaderNodeFloatFunc_degrees";
		function_names[Function::FUNC_EXP2] = "ND_MTL_exp2_float";
		function_names[Function::FUNC_INVERSE_SQRT] = "ND_MTL_rsqrt_float";
		function_names[Function::FUNC_LOG2] = "ND_MTL_log2_float";
		function_names[Function::FUNC_RADIANS] = "VisualShaderNodeFloatFunc_radians";
		function_names[Function::FUNC_RECIPROCAL] = "VisualShaderNodeFloatFunc_reciprocal";
		function_names[Function::FUNC_ROUNDEVEN] = "VisualShaderNodeFloatFunc_roundeven";
		function_names[Function::FUNC_TRUNC] = "ND_trunc_float";
		function_names[Function::FUNC_ONEMINUS] = "ND_realitykit_oneminus_float";
	})

	DECLARATION(p_shader_type, p_context) {
		p_context.code_parts.push_back(R"""(
			let VisualShaderNodeFloatFunc_saturate = { (v) in ND_clamp_float(v, 0.0f, 1.0f) }
			let VisualShaderNodeFloatFunc_negate = { (v) in ND_multiply_float(v, -1.0f) }
			let VisualShaderNodeFloatFunc_degrees = { (v) in ND_multiply_float(v, 57.29577951308232f) }
			let VisualShaderNodeFloatFunc_radians = { (v) in ND_multiply_float(v, 0.017453292519943295f) }
			let VisualShaderNodeFloatFunc_reciprocal = { (v) in ND_divide_float(1.0f, v) }
			let VisualShaderNodeFloatFunc_roundeven = { (v) in ND_round_float(ND_multiply_float(v, 0.5f)) }
		)""");
	}

	ANALYZE(p_context, p_node_wrapper) {
		Function func = UNWRAP()->get_function();
		if (func > Function::FUNC_MAX) {
			p_context.errors.push_back(std::format("godot::VisualShaderNodeFloatFunc: Unknown operator: {}", (uint32_t) func));
			return;
		}
	}

	EXPRESSION(p_context, p_node_wrapper) {
		const char* function_name = function_names[UNWRAP()->get_function()];
		OUTPUT_EXPRESSION(0, std::format("{}({})", function_name, INPUT_EXPRESSION(0)));
	}
END(VisualShaderNodeFloatFunc)
