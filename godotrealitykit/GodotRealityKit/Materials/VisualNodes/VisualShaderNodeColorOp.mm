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
#include <godot_cpp/classes/visual_shader_node_color_op.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeColorOp)
	INLET_COUNT(2)
	INPUT_TYPE(PortType::VEC3F)
    OUTPUT_TYPE(PortType::VEC3F)
	
	using Operator = godot::VisualShaderNodeColorOp::Operator;
	static const char* function_names[Operator::OP_MAX] = { nullptr };

	STATIC_INIT({
		function_names[Operator::OP_SCREEN] = "VisualShaderNodeColorOp_screen";
		function_names[Operator::OP_DIFFERENCE] = "VisualShaderNodeColorOp_difference";
		function_names[Operator::OP_DARKEN] = "VisualShaderNodeColorOp_darken";
		function_names[Operator::OP_LIGHTEN] = "VisualShaderNodeColorOp_lighten";
		function_names[Operator::OP_OVERLAY] = "VisualShaderNodeColorOp_overlay";
		function_names[Operator::OP_DODGE] = "VisualShaderNodeColorOp_dodge";
		function_names[Operator::OP_BURN] = "VisualShaderNodeColorOp_burn";
		function_names[Operator::OP_SOFT_LIGHT] = "VisualShaderNodeColorOp_soft_light";
		function_names[Operator::OP_HARD_LIGHT] = "VisualShaderNodeColorOp_hard_light";
	})

	DECLARATION(p_shader_type, p_context) {
		// See Node documentation here: https://docs.godotengine.org/en/stable/classes/class_visualshadernodecolorop.html
		// Formulas match Godot source visual_shader_nodes.cpp lines 2403-2470.
		// base = a (port 0), blend = b (port 1).
		// Per-channel conditionals follow the linear_to_srgb pattern in snippets.h:
		//   ND_ifgreater_float(value, threshold, trueVal, falseVal) = if value > threshold
		p_context.code_parts.push_back(R"""(
			let VisualShaderNodeColorOp_screen = { (a, b) in
				let atmp = ND_subtract_vector3((1.0f, 1.0f, 1.0f), a);
				let btmp = ND_subtract_vector3((1.0f, 1.0f, 1.0f), b);
				let abtmp = ND_multiply_vector3(atmp, btmp);
				ND_subtract_vector3((1.0f, 1.0f, 1.0f), abtmp)
			};
			let VisualShaderNodeColorOp_difference = { (a, b) in
				ND_absval_vector3(ND_subtract_vector3(a, b))
			};
			let VisualShaderNodeColorOp_darken = { (a, b) in
				ND_min_vector3(a, b)
			};
			let VisualShaderNodeColorOp_lighten = { (a, b) in
				ND_max_vector3(a, b)
			};
			let VisualShaderNodeColorOp_overlay = { (a, b) in
				let dark = ND_multiply_vector3FA(ND_multiply_vector3(a, b), 2.0f);
				let light = ND_subtract_vector3((1.0f, 1.0f, 1.0f), ND_multiply_vector3FA(ND_multiply_vector3(ND_subtract_vector3((1.0f, 1.0f, 1.0f), b), ND_subtract_vector3((1.0f, 1.0f, 1.0f), a)), 2.0f));
				let mask = ND_realitykit_step_vector3(a, ND_combine3_vector3(0.5f, 0.5f, 0.5f));
				ND_add_vector3(dark, ND_multiply_vector3(mask, ND_subtract_vector3(light, dark)))
			};
			let VisualShaderNodeColorOp_dodge = { (a, b) in
				ND_divide_vector3(a, ND_subtract_vector3((1.0f, 1.0f, 1.0f), b))
			};
			let VisualShaderNodeColorOp_burn = { (a, b) in
				ND_subtract_vector3((1.0f, 1.0f, 1.0f), ND_divide_vector3(ND_subtract_vector3((1.0f, 1.0f, 1.0f), a), b))
			};
			let VisualShaderNodeColorOp_soft_light = { (a, b) in
				let dark = ND_multiply_vector3(a, ND_add_vector3FA(b, 0.5f));
				let light = ND_subtract_vector3((1.0f, 1.0f, 1.0f), ND_multiply_vector3(ND_subtract_vector3((1.0f, 1.0f, 1.0f), a), ND_subtract_vector3((1.5f, 1.5f, 1.5f), b)));
				let mask = ND_realitykit_step_vector3(a, ND_combine3_vector3(0.5f, 0.5f, 0.5f));
				ND_add_vector3(dark, ND_multiply_vector3(mask, ND_subtract_vector3(light, dark)))
			};
			let VisualShaderNodeColorOp_hard_light = { (a, b) in
				let dark = ND_multiply_vector3FA(ND_multiply_vector3(a, b), 2.0f);
				let light = ND_subtract_vector3((1.0f, 1.0f, 1.0f), ND_multiply_vector3FA(ND_multiply_vector3(ND_subtract_vector3((1.0f, 1.0f, 1.0f), a), ND_subtract_vector3((1.0f, 1.0f, 1.0f), b)), 2.0f));
				let mask = ND_realitykit_step_vector3(a, ND_combine3_vector3(0.5f, 0.5f, 0.5f));
				ND_add_vector3(dark, ND_multiply_vector3(mask, ND_subtract_vector3(light, dark)))
			};
		)""");
	}

	EXPRESSION(p_context, p_node_wrapper) {
		Operator op = UNWRAP()->get_operator();
		
		if (op > Operator::OP_MAX) {
			p_context.errors.push_back(std::format("godot::VisualShaderNodeColorOp: Unknown operator: {}", (uint32_t) op));
			return;
		}
		const char* function_name = function_names[op];
		if (!function_name) {
			p_context.errors.push_back(std::format("godot::VisualShaderNodeColorOp: Unsupported operator: {}", (uint32_t) op));
			return;
		}
		
		OUTPUT_EXPRESSION(0, std::format("{}({}, {})", function_name, INPUT_EXPRESSION(0), INPUT_EXPRESSION(1)));
	}
END(VisualShaderNodeColorOp)
