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
#include <godot_cpp/classes/visual_shader_node_compare.hpp>

#include <format>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeCompare)
	using ComparisonType = godot::VisualShaderNodeCompare::ComparisonType;
	using Function = godot::VisualShaderNodeCompare::Function;
	using Condition = godot::VisualShaderNodeCompare::Condition;

	static PortType input_types[ComparisonType::CTYPE_MAX];
	static const char* function_names[ComparisonType::CTYPE_MAX][Function::FUNC_MAX][Condition::COND_MAX];

	INLET_COUNT(3)
	INPUT_TYPE_F(p_node_wrapper, p_index_param) {
		ComparisonType ctype = UNWRAP()->get_comparison_type();
		if (ctype >= ComparisonType::CTYPE_MAX) {
			return PortType::UNDEFINED;
		}
		if (p_index_param == 2) {
			// Port 2 is the tolerance and only exists for scalar float comparisons
			return ctype == ComparisonType::CTYPE_SCALAR ? PortType::FLOAT : PortType::UNDEFINED;
		}
		return input_types[ctype];
	}

	OUTPUT_TYPE(PortType::BOOL)

	STATIC_INIT({
		input_types[ComparisonType::CTYPE_SCALAR]     = PortType::FLOAT;
		input_types[ComparisonType::CTYPE_SCALAR_INT] = PortType::INT;
		input_types[ComparisonType::CTYPE_SCALAR_UINT]= PortType::INT;
		input_types[ComparisonType::CTYPE_VECTOR_2D]  = PortType::VEC2F;
		input_types[ComparisonType::CTYPE_VECTOR_3D]  = PortType::VEC3F;
		input_types[ComparisonType::CTYPE_VECTOR_4D]  = PortType::VEC4F;
		input_types[ComparisonType::CTYPE_BOOLEAN]    = PortType::BOOL;
		input_types[ComparisonType::CTYPE_TRANSFORM]  = PortType::TRANSFORM3D;

		// Scalar float — condition is irrelevant, fill both slots identically
		for (int c = 0; c < Condition::COND_MAX; c++) {
			function_names[ComparisonType::CTYPE_SCALAR][Function::FUNC_EQUAL][c]              = "VisualShaderNodeCompare_eq_float";
			function_names[ComparisonType::CTYPE_SCALAR][Function::FUNC_NOT_EQUAL][c]          = "VisualShaderNodeCompare_neq_float";
			function_names[ComparisonType::CTYPE_SCALAR][Function::FUNC_GREATER_THAN][c]       = "VisualShaderNodeCompare_gt_float";
			function_names[ComparisonType::CTYPE_SCALAR][Function::FUNC_GREATER_THAN_EQUAL][c] = "VisualShaderNodeCompare_gte_float";
			function_names[ComparisonType::CTYPE_SCALAR][Function::FUNC_LESS_THAN][c]          = "VisualShaderNodeCompare_lt_float";
			function_names[ComparisonType::CTYPE_SCALAR][Function::FUNC_LESS_THAN_EQUAL][c]    = "VisualShaderNodeCompare_lte_float";
		}

		// Scalar int — condition is irrelevant, UINT mapped to INT helpers
		for (auto ct : { ComparisonType::CTYPE_SCALAR_INT, ComparisonType::CTYPE_SCALAR_UINT }) {
			for (int c = 0; c < Condition::COND_MAX; c++) {
				function_names[ct][Function::FUNC_EQUAL][c]              = "VisualShaderNodeCompare_eq_int";
				function_names[ct][Function::FUNC_NOT_EQUAL][c]          = "VisualShaderNodeCompare_neq_int";
				function_names[ct][Function::FUNC_GREATER_THAN][c]       = "VisualShaderNodeCompare_gt_int";
				function_names[ct][Function::FUNC_GREATER_THAN_EQUAL][c] = "VisualShaderNodeCompare_gte_int";
				function_names[ct][Function::FUNC_LESS_THAN][c]          = "VisualShaderNodeCompare_lt_int";
				function_names[ct][Function::FUNC_LESS_THAN_EQUAL][c]    = "VisualShaderNodeCompare_lte_int";
			}
		}

		// Boolean — only == and != are valid; order/magnitude comparisons are nullptr
		for (int c = 0; c < Condition::COND_MAX; c++) {
			function_names[ComparisonType::CTYPE_BOOLEAN][Function::FUNC_EQUAL][c]     = "VisualShaderNodeCompare_eq_bool";
			function_names[ComparisonType::CTYPE_BOOLEAN][Function::FUNC_NOT_EQUAL][c] = "VisualShaderNodeCompare_neq_bool";
		}

		// Vector 2D — ALL (index 0) / ANY (index 1)
		function_names[ComparisonType::CTYPE_VECTOR_2D][Function::FUNC_EQUAL][Condition::COND_ALL]              = "VisualShaderNodeCompare_eq_vec2_all";
		function_names[ComparisonType::CTYPE_VECTOR_2D][Function::FUNC_EQUAL][Condition::COND_ANY]              = "VisualShaderNodeCompare_eq_vec2_any";
		function_names[ComparisonType::CTYPE_VECTOR_2D][Function::FUNC_NOT_EQUAL][Condition::COND_ALL]          = "VisualShaderNodeCompare_neq_vec2_all";
		function_names[ComparisonType::CTYPE_VECTOR_2D][Function::FUNC_NOT_EQUAL][Condition::COND_ANY]          = "VisualShaderNodeCompare_neq_vec2_any";
		function_names[ComparisonType::CTYPE_VECTOR_2D][Function::FUNC_GREATER_THAN][Condition::COND_ALL]       = "VisualShaderNodeCompare_gt_vec2_all";
		function_names[ComparisonType::CTYPE_VECTOR_2D][Function::FUNC_GREATER_THAN][Condition::COND_ANY]       = "VisualShaderNodeCompare_gt_vec2_any";
		function_names[ComparisonType::CTYPE_VECTOR_2D][Function::FUNC_GREATER_THAN_EQUAL][Condition::COND_ALL] = "VisualShaderNodeCompare_gte_vec2_all";
		function_names[ComparisonType::CTYPE_VECTOR_2D][Function::FUNC_GREATER_THAN_EQUAL][Condition::COND_ANY] = "VisualShaderNodeCompare_gte_vec2_any";
		function_names[ComparisonType::CTYPE_VECTOR_2D][Function::FUNC_LESS_THAN][Condition::COND_ALL]          = "VisualShaderNodeCompare_lt_vec2_all";
		function_names[ComparisonType::CTYPE_VECTOR_2D][Function::FUNC_LESS_THAN][Condition::COND_ANY]          = "VisualShaderNodeCompare_lt_vec2_any";
		function_names[ComparisonType::CTYPE_VECTOR_2D][Function::FUNC_LESS_THAN_EQUAL][Condition::COND_ALL]    = "VisualShaderNodeCompare_lte_vec2_all";
		function_names[ComparisonType::CTYPE_VECTOR_2D][Function::FUNC_LESS_THAN_EQUAL][Condition::COND_ANY]    = "VisualShaderNodeCompare_lte_vec2_any";

		// Vector 3D
		function_names[ComparisonType::CTYPE_VECTOR_3D][Function::FUNC_EQUAL][Condition::COND_ALL]              = "VisualShaderNodeCompare_eq_vec3_all";
		function_names[ComparisonType::CTYPE_VECTOR_3D][Function::FUNC_EQUAL][Condition::COND_ANY]              = "VisualShaderNodeCompare_eq_vec3_any";
		function_names[ComparisonType::CTYPE_VECTOR_3D][Function::FUNC_NOT_EQUAL][Condition::COND_ALL]          = "VisualShaderNodeCompare_neq_vec3_all";
		function_names[ComparisonType::CTYPE_VECTOR_3D][Function::FUNC_NOT_EQUAL][Condition::COND_ANY]          = "VisualShaderNodeCompare_neq_vec3_any";
		function_names[ComparisonType::CTYPE_VECTOR_3D][Function::FUNC_GREATER_THAN][Condition::COND_ALL]       = "VisualShaderNodeCompare_gt_vec3_all";
		function_names[ComparisonType::CTYPE_VECTOR_3D][Function::FUNC_GREATER_THAN][Condition::COND_ANY]       = "VisualShaderNodeCompare_gt_vec3_any";
		function_names[ComparisonType::CTYPE_VECTOR_3D][Function::FUNC_GREATER_THAN_EQUAL][Condition::COND_ALL] = "VisualShaderNodeCompare_gte_vec3_all";
		function_names[ComparisonType::CTYPE_VECTOR_3D][Function::FUNC_GREATER_THAN_EQUAL][Condition::COND_ANY] = "VisualShaderNodeCompare_gte_vec3_any";
		function_names[ComparisonType::CTYPE_VECTOR_3D][Function::FUNC_LESS_THAN][Condition::COND_ALL]          = "VisualShaderNodeCompare_lt_vec3_all";
		function_names[ComparisonType::CTYPE_VECTOR_3D][Function::FUNC_LESS_THAN][Condition::COND_ANY]          = "VisualShaderNodeCompare_lt_vec3_any";
		function_names[ComparisonType::CTYPE_VECTOR_3D][Function::FUNC_LESS_THAN_EQUAL][Condition::COND_ALL]    = "VisualShaderNodeCompare_lte_vec3_all";
		function_names[ComparisonType::CTYPE_VECTOR_3D][Function::FUNC_LESS_THAN_EQUAL][Condition::COND_ANY]    = "VisualShaderNodeCompare_lte_vec3_any";

		// Vector 4D
		function_names[ComparisonType::CTYPE_VECTOR_4D][Function::FUNC_EQUAL][Condition::COND_ALL]              = "VisualShaderNodeCompare_eq_vec4_all";
		function_names[ComparisonType::CTYPE_VECTOR_4D][Function::FUNC_EQUAL][Condition::COND_ANY]              = "VisualShaderNodeCompare_eq_vec4_any";
		function_names[ComparisonType::CTYPE_VECTOR_4D][Function::FUNC_NOT_EQUAL][Condition::COND_ALL]          = "VisualShaderNodeCompare_neq_vec4_all";
		function_names[ComparisonType::CTYPE_VECTOR_4D][Function::FUNC_NOT_EQUAL][Condition::COND_ANY]          = "VisualShaderNodeCompare_neq_vec4_any";
		function_names[ComparisonType::CTYPE_VECTOR_4D][Function::FUNC_GREATER_THAN][Condition::COND_ALL]       = "VisualShaderNodeCompare_gt_vec4_all";
		function_names[ComparisonType::CTYPE_VECTOR_4D][Function::FUNC_GREATER_THAN][Condition::COND_ANY]       = "VisualShaderNodeCompare_gt_vec4_any";
		function_names[ComparisonType::CTYPE_VECTOR_4D][Function::FUNC_GREATER_THAN_EQUAL][Condition::COND_ALL] = "VisualShaderNodeCompare_gte_vec4_all";
		function_names[ComparisonType::CTYPE_VECTOR_4D][Function::FUNC_GREATER_THAN_EQUAL][Condition::COND_ANY] = "VisualShaderNodeCompare_gte_vec4_any";
		function_names[ComparisonType::CTYPE_VECTOR_4D][Function::FUNC_LESS_THAN][Condition::COND_ALL]          = "VisualShaderNodeCompare_lt_vec4_all";
		function_names[ComparisonType::CTYPE_VECTOR_4D][Function::FUNC_LESS_THAN][Condition::COND_ANY]          = "VisualShaderNodeCompare_lt_vec4_any";
		function_names[ComparisonType::CTYPE_VECTOR_4D][Function::FUNC_LESS_THAN_EQUAL][Condition::COND_ALL]    = "VisualShaderNodeCompare_lte_vec4_all";
		function_names[ComparisonType::CTYPE_VECTOR_4D][Function::FUNC_LESS_THAN_EQUAL][Condition::COND_ANY]    = "VisualShaderNodeCompare_lte_vec4_any";
	});

	DECLARATION(shader_type, p_context) {
		p_context.code_parts.push_back(R"""(
		let VisualShaderNodeCompare_eq_float  = { (a, b, tol) in float_to_bool(ND_ifgreatereq_float(tol, ND_absval_float(ND_subtract_float(a, b)), 1.0f, 0.0f)) };
		let VisualShaderNodeCompare_neq_float = { (a, b, tol) in float_to_bool(ND_ifgreater_float(ND_absval_float(ND_subtract_float(a, b)), tol, 1.0f, 0.0f)) };
		let VisualShaderNodeCompare_gt_float  = { (a, b) in float_to_bool(ND_ifgreater_float(a, b, 1.0f, 0.0f)) };
		let VisualShaderNodeCompare_gte_float = { (a, b) in float_to_bool(ND_ifgreatereq_float(a, b, 1.0f, 0.0f)) };
		let VisualShaderNodeCompare_lt_float  = { (a, b) in float_to_bool(ND_ifgreater_float(b, a, 1.0f, 0.0f)) };
		let VisualShaderNodeCompare_lte_float = { (a, b) in float_to_bool(ND_ifgreatereq_float(b, a, 1.0f, 0.0f)) };

		let VisualShaderNodeCompare_eq_int  = { (a, b) in float_to_bool(ND_ifequal_floatI(a, b, 1.0f, 0.0f)) };
		let VisualShaderNodeCompare_neq_int = { (a, b) in float_to_bool(ND_ifequal_floatI(a, b, 0.0f, 1.0f)) };
		let VisualShaderNodeCompare_gt_int  = { (a, b) in float_to_bool(ND_ifgreater_floatI(a, b, 1.0f, 0.0f)) };
		let VisualShaderNodeCompare_gte_int = { (a, b) in float_to_bool(ND_ifgreatereq_floatI(a, b, 1.0f, 0.0f)) };
		let VisualShaderNodeCompare_lt_int  = { (a, b) in float_to_bool(ND_ifgreater_floatI(b, a, 1.0f, 0.0f)) };
		let VisualShaderNodeCompare_lte_int = { (a, b) in float_to_bool(ND_ifgreatereq_floatI(b, a, 1.0f, 0.0f)) };

		let VisualShaderNodeCompare_eq_bool  = { (a, b) in
			let af = bool_to_float(a);
			let bf = bool_to_float(b);
			float_to_bool(ND_ifequal_float(af, bf, 1.0f, 0.0f))
		};
		let VisualShaderNodeCompare_neq_bool = { (a, b) in
			let af = bool_to_float(a);
			let bf = bool_to_float(b);
			float_to_bool(ND_ifequal_float(af, bf, 0.0f, 1.0f))
		};
		let VisualShaderNodeCompare_eq_vec2_all  = { (a, b) in
			let cx = ND_ifequal_float(v2_x(a), v2_x(b), 1.0f, 0.0f);
			let cy = ND_ifequal_float(v2_y(a), v2_y(b), 1.0f, 0.0f);
			float_to_bool(ND_multiply_float(cx, cy))
		};
		let VisualShaderNodeCompare_eq_vec2_any  = { (a, b) in
			let cx = ND_ifequal_float(v2_x(a), v2_x(b), 1.0f, 0.0f);
			let cy = ND_ifequal_float(v2_y(a), v2_y(b), 1.0f, 0.0f);
			float_to_bool(ND_add_float(cx, cy))
		};
		let VisualShaderNodeCompare_neq_vec2_all = { (a, b) in
			let cx = ND_ifequal_float(v2_x(a), v2_x(b), 0.0f, 1.0f);
			let cy = ND_ifequal_float(v2_y(a), v2_y(b), 0.0f, 1.0f);
			float_to_bool(ND_multiply_float(cx, cy))
		};
		let VisualShaderNodeCompare_neq_vec2_any = { (a, b) in
			let cx = ND_ifequal_float(v2_x(a), v2_x(b), 0.0f, 1.0f);
			let cy = ND_ifequal_float(v2_y(a), v2_y(b), 0.0f, 1.0f);
			float_to_bool(ND_add_float(cx, cy))
		};
		let VisualShaderNodeCompare_gt_vec2_all  = { (a, b) in
			let cx = ND_ifgreater_float(v2_x(a), v2_x(b), 1.0f, 0.0f);
			let cy = ND_ifgreater_float(v2_y(a), v2_y(b), 1.0f, 0.0f);
			float_to_bool(ND_multiply_float(cx, cy))
		};
		let VisualShaderNodeCompare_gt_vec2_any  = { (a, b) in
			let cx = ND_ifgreater_float(v2_x(a), v2_x(b), 1.0f, 0.0f);
			let cy = ND_ifgreater_float(v2_y(a), v2_y(b), 1.0f, 0.0f);
			float_to_bool(ND_add_float(cx, cy))
		};
		let VisualShaderNodeCompare_gte_vec2_all = { (a, b) in
			let cx = ND_ifgreatereq_float(v2_x(a), v2_x(b), 1.0f, 0.0f);
			let cy = ND_ifgreatereq_float(v2_y(a), v2_y(b), 1.0f, 0.0f);
			float_to_bool(ND_multiply_float(cx, cy))
		};
		let VisualShaderNodeCompare_gte_vec2_any = { (a, b) in
			let cx = ND_ifgreatereq_float(v2_x(a), v2_x(b), 1.0f, 0.0f);
			let cy = ND_ifgreatereq_float(v2_y(a), v2_y(b), 1.0f, 0.0f);
			float_to_bool(ND_add_float(cx, cy))
		};
		let VisualShaderNodeCompare_lt_vec2_all  = { (a, b) in
			let cx = ND_ifgreater_float(v2_x(b), v2_x(a), 1.0f, 0.0f);
			let cy = ND_ifgreater_float(v2_y(b), v2_y(a), 1.0f, 0.0f);
			float_to_bool(ND_multiply_float(cx, cy))
		};
		let VisualShaderNodeCompare_lt_vec2_any  = { (a, b) in
			let cx = ND_ifgreater_float(v2_x(b), v2_x(a), 1.0f, 0.0f);
			let cy = ND_ifgreater_float(v2_y(b), v2_y(a), 1.0f, 0.0f);
			float_to_bool(ND_add_float(cx, cy))
		};
		let VisualShaderNodeCompare_lte_vec2_all = { (a, b) in
			let cx = ND_ifgreatereq_float(v2_x(b), v2_x(a), 1.0f, 0.0f);
			let cy = ND_ifgreatereq_float(v2_y(b), v2_y(a), 1.0f, 0.0f);
			float_to_bool(ND_multiply_float(cx, cy))
		};
		let VisualShaderNodeCompare_lte_vec2_any = { (a, b) in
			let cx = ND_ifgreatereq_float(v2_x(b), v2_x(a), 1.0f, 0.0f);
			let cy = ND_ifgreatereq_float(v2_y(b), v2_y(a), 1.0f, 0.0f);
			float_to_bool(ND_add_float(cx, cy))
		};
		let VisualShaderNodeCompare_eq_vec3_all  = { (a, b) in
			let cx = ND_ifequal_float(v3_x(a), v3_x(b), 1.0f, 0.0f);
			let cy = ND_ifequal_float(v3_y(a), v3_y(b), 1.0f, 0.0f);
			let cz = ND_ifequal_float(v3_z(a), v3_z(b), 1.0f, 0.0f);
			float_to_bool(ND_multiply_float(cx, ND_multiply_float(cy, cz)))
		};
		let VisualShaderNodeCompare_eq_vec3_any  = { (a, b) in
			let cx = ND_ifequal_float(v3_x(a), v3_x(b), 1.0f, 0.0f);
			let cy = ND_ifequal_float(v3_y(a), v3_y(b), 1.0f, 0.0f);
			let cz = ND_ifequal_float(v3_z(a), v3_z(b), 1.0f, 0.0f);
			float_to_bool(ND_add_float(cx, ND_add_float(cy, cz)))
		};
		let VisualShaderNodeCompare_neq_vec3_all = { (a, b) in
			let cx = ND_ifequal_float(v3_x(a), v3_x(b), 0.0f, 1.0f);
			let cy = ND_ifequal_float(v3_y(a), v3_y(b), 0.0f, 1.0f);
			let cz = ND_ifequal_float(v3_z(a), v3_z(b), 0.0f, 1.0f);
			float_to_bool(ND_multiply_float(cx, ND_multiply_float(cy, cz)))
		};
		let VisualShaderNodeCompare_neq_vec3_any = { (a, b) in
			let cx = ND_ifequal_float(v3_x(a), v3_x(b), 0.0f, 1.0f);
			let cy = ND_ifequal_float(v3_y(a), v3_y(b), 0.0f, 1.0f);
			let cz = ND_ifequal_float(v3_z(a), v3_z(b), 0.0f, 1.0f);
			float_to_bool(ND_add_float(cx, ND_add_float(cy, cz)))
		};
		let VisualShaderNodeCompare_gt_vec3_all  = { (a, b) in
			let cx = ND_ifgreater_float(v3_x(a), v3_x(b), 1.0f, 0.0f);
			let cy = ND_ifgreater_float(v3_y(a), v3_y(b), 1.0f, 0.0f);
			let cz = ND_ifgreater_float(v3_z(a), v3_z(b), 1.0f, 0.0f);
			float_to_bool(ND_multiply_float(cx, ND_multiply_float(cy, cz)))
		};
		let VisualShaderNodeCompare_gt_vec3_any  = { (a, b) in
			let cx = ND_ifgreater_float(v3_x(a), v3_x(b), 1.0f, 0.0f);
			let cy = ND_ifgreater_float(v3_y(a), v3_y(b), 1.0f, 0.0f);
			let cz = ND_ifgreater_float(v3_z(a), v3_z(b), 1.0f, 0.0f);
			float_to_bool(ND_add_float(cx, ND_add_float(cy, cz)))
		};
		let VisualShaderNodeCompare_gte_vec3_all = { (a, b) in
			let cx = ND_ifgreatereq_float(v3_x(a), v3_x(b), 1.0f, 0.0f);
			let cy = ND_ifgreatereq_float(v3_y(a), v3_y(b), 1.0f, 0.0f);
			let cz = ND_ifgreatereq_float(v3_z(a), v3_z(b), 1.0f, 0.0f);
			float_to_bool(ND_multiply_float(cx, ND_multiply_float(cy, cz)))
		};
		let VisualShaderNodeCompare_gte_vec3_any = { (a, b) in
			let cx = ND_ifgreatereq_float(v3_x(a), v3_x(b), 1.0f, 0.0f);
			let cy = ND_ifgreatereq_float(v3_y(a), v3_y(b), 1.0f, 0.0f);
			let cz = ND_ifgreatereq_float(v3_z(a), v3_z(b), 1.0f, 0.0f);
			float_to_bool(ND_add_float(cx, ND_add_float(cy, cz)))
		};
		let VisualShaderNodeCompare_lt_vec3_all  = { (a, b) in
			let cx = ND_ifgreater_float(v3_x(b), v3_x(a), 1.0f, 0.0f);
			let cy = ND_ifgreater_float(v3_y(b), v3_y(a), 1.0f, 0.0f);
			let cz = ND_ifgreater_float(v3_z(b), v3_z(a), 1.0f, 0.0f);
			float_to_bool(ND_multiply_float(cx, ND_multiply_float(cy, cz)))
		};
		let VisualShaderNodeCompare_lt_vec3_any  = { (a, b) in
			let cx = ND_ifgreater_float(v3_x(b), v3_x(a), 1.0f, 0.0f);
			let cy = ND_ifgreater_float(v3_y(b), v3_y(a), 1.0f, 0.0f);
			let cz = ND_ifgreater_float(v3_z(b), v3_z(a), 1.0f, 0.0f);
			float_to_bool(ND_add_float(cx, ND_add_float(cy, cz)))
		};
		let VisualShaderNodeCompare_lte_vec3_all = { (a, b) in
			let cx = ND_ifgreatereq_float(v3_x(b), v3_x(a), 1.0f, 0.0f);
			let cy = ND_ifgreatereq_float(v3_y(b), v3_y(a), 1.0f, 0.0f);
			let cz = ND_ifgreatereq_float(v3_z(b), v3_z(a), 1.0f, 0.0f);
			float_to_bool(ND_multiply_float(cx, ND_multiply_float(cy, cz)))
		};
		let VisualShaderNodeCompare_lte_vec3_any = { (a, b) in
			let cx = ND_ifgreatereq_float(v3_x(b), v3_x(a), 1.0f, 0.0f);
			let cy = ND_ifgreatereq_float(v3_y(b), v3_y(a), 1.0f, 0.0f);
			let cz = ND_ifgreatereq_float(v3_z(b), v3_z(a), 1.0f, 0.0f);
			float_to_bool(ND_add_float(cx, ND_add_float(cy, cz)))
		};
		let VisualShaderNodeCompare_eq_vec4_all  = { (a, b) in
			let cx = ND_ifequal_float(v4_x(a), v4_x(b), 1.0f, 0.0f);
			let cy = ND_ifequal_float(v4_y(a), v4_y(b), 1.0f, 0.0f);
			let cz = ND_ifequal_float(v4_z(a), v4_z(b), 1.0f, 0.0f);
			let cw = ND_ifequal_float(v4_w(a), v4_w(b), 1.0f, 0.0f);
			float_to_bool(ND_multiply_float(cx, ND_multiply_float(cy, ND_multiply_float(cz, cw))))
		};
		let VisualShaderNodeCompare_eq_vec4_any  = { (a, b) in
			let cx = ND_ifequal_float(v4_x(a), v4_x(b), 1.0f, 0.0f);
			let cy = ND_ifequal_float(v4_y(a), v4_y(b), 1.0f, 0.0f);
			let cz = ND_ifequal_float(v4_z(a), v4_z(b), 1.0f, 0.0f);
			let cw = ND_ifequal_float(v4_w(a), v4_w(b), 1.0f, 0.0f);
			float_to_bool(ND_add_float(cx, ND_add_float(cy, ND_add_float(cz, cw))))
		};
		let VisualShaderNodeCompare_neq_vec4_all = { (a, b) in
			let cx = ND_ifequal_float(v4_x(a), v4_x(b), 0.0f, 1.0f);
			let cy = ND_ifequal_float(v4_y(a), v4_y(b), 0.0f, 1.0f);
			let cz = ND_ifequal_float(v4_z(a), v4_z(b), 0.0f, 1.0f);
			let cw = ND_ifequal_float(v4_w(a), v4_w(b), 0.0f, 1.0f);
			float_to_bool(ND_multiply_float(cx, ND_multiply_float(cy, ND_multiply_float(cz, cw))))
		};
		let VisualShaderNodeCompare_neq_vec4_any = { (a, b) in
			let cx = ND_ifequal_float(v4_x(a), v4_x(b), 0.0f, 1.0f);
			let cy = ND_ifequal_float(v4_y(a), v4_y(b), 0.0f, 1.0f);
			let cz = ND_ifequal_float(v4_z(a), v4_z(b), 0.0f, 1.0f);
			let cw = ND_ifequal_float(v4_w(a), v4_w(b), 0.0f, 1.0f);
			float_to_bool(ND_add_float(cx, ND_add_float(cy, ND_add_float(cz, cw))))
		};
		let VisualShaderNodeCompare_gt_vec4_all  = { (a, b) in
			let cx = ND_ifgreater_float(v4_x(a), v4_x(b), 1.0f, 0.0f);
			let cy = ND_ifgreater_float(v4_y(a), v4_y(b), 1.0f, 0.0f);
			let cz = ND_ifgreater_float(v4_z(a), v4_z(b), 1.0f, 0.0f);
			let cw = ND_ifgreater_float(v4_w(a), v4_w(b), 1.0f, 0.0f);
			float_to_bool(ND_multiply_float(cx, ND_multiply_float(cy, ND_multiply_float(cz, cw))))
		};
		let VisualShaderNodeCompare_gt_vec4_any  = { (a, b) in
			let cx = ND_ifgreater_float(v4_x(a), v4_x(b), 1.0f, 0.0f);
			let cy = ND_ifgreater_float(v4_y(a), v4_y(b), 1.0f, 0.0f);
			let cz = ND_ifgreater_float(v4_z(a), v4_z(b), 1.0f, 0.0f);
			let cw = ND_ifgreater_float(v4_w(a), v4_w(b), 1.0f, 0.0f);
			float_to_bool(ND_add_float(cx, ND_add_float(cy, ND_add_float(cz, cw))))
		};
		let VisualShaderNodeCompare_gte_vec4_all = { (a, b) in
			let cx = ND_ifgreatereq_float(v4_x(a), v4_x(b), 1.0f, 0.0f);
			let cy = ND_ifgreatereq_float(v4_y(a), v4_y(b), 1.0f, 0.0f);
			let cz = ND_ifgreatereq_float(v4_z(a), v4_z(b), 1.0f, 0.0f);
			let cw = ND_ifgreatereq_float(v4_w(a), v4_w(b), 1.0f, 0.0f);
			float_to_bool(ND_multiply_float(cx, ND_multiply_float(cy, ND_multiply_float(cz, cw))))
		};
		let VisualShaderNodeCompare_gte_vec4_any = { (a, b) in
			let cx = ND_ifgreatereq_float(v4_x(a), v4_x(b), 1.0f, 0.0f);
			let cy = ND_ifgreatereq_float(v4_y(a), v4_y(b), 1.0f, 0.0f);
			let cz = ND_ifgreatereq_float(v4_z(a), v4_z(b), 1.0f, 0.0f);
			let cw = ND_ifgreatereq_float(v4_w(a), v4_w(b), 1.0f, 0.0f);
			float_to_bool(ND_add_float(cx, ND_add_float(cy, ND_add_float(cz, cw))))
		};
		let VisualShaderNodeCompare_lt_vec4_all  = { (a, b) in
			let cx = ND_ifgreater_float(v4_x(b), v4_x(a), 1.0f, 0.0f);
			let cy = ND_ifgreater_float(v4_y(b), v4_y(a), 1.0f, 0.0f);
			let cz = ND_ifgreater_float(v4_z(b), v4_z(a), 1.0f, 0.0f);
			let cw = ND_ifgreater_float(v4_w(b), v4_w(a), 1.0f, 0.0f);
			float_to_bool(ND_multiply_float(cx, ND_multiply_float(cy, ND_multiply_float(cz, cw))))
		};
		let VisualShaderNodeCompare_lt_vec4_any  = { (a, b) in
			let cx = ND_ifgreater_float(v4_x(b), v4_x(a), 1.0f, 0.0f);
			let cy = ND_ifgreater_float(v4_y(b), v4_y(a), 1.0f, 0.0f);
			let cz = ND_ifgreater_float(v4_z(b), v4_z(a), 1.0f, 0.0f);
			let cw = ND_ifgreater_float(v4_w(b), v4_w(a), 1.0f, 0.0f);
			float_to_bool(ND_add_float(cx, ND_add_float(cy, ND_add_float(cz, cw))))
		};
		let VisualShaderNodeCompare_lte_vec4_all = { (a, b) in
			let cx = ND_ifgreatereq_float(v4_x(b), v4_x(a), 1.0f, 0.0f);
			let cy = ND_ifgreatereq_float(v4_y(b), v4_y(a), 1.0f, 0.0f);
			let cz = ND_ifgreatereq_float(v4_z(b), v4_z(a), 1.0f, 0.0f);
			let cw = ND_ifgreatereq_float(v4_w(b), v4_w(a), 1.0f, 0.0f);
			float_to_bool(ND_multiply_float(cx, ND_multiply_float(cy, ND_multiply_float(cz, cw))))
		};
		let VisualShaderNodeCompare_lte_vec4_any = { (a, b) in
			let cx = ND_ifgreatereq_float(v4_x(b), v4_x(a), 1.0f, 0.0f);
			let cy = ND_ifgreatereq_float(v4_y(b), v4_y(a), 1.0f, 0.0f);
			let cz = ND_ifgreatereq_float(v4_z(b), v4_z(a), 1.0f, 0.0f);
			let cw = ND_ifgreatereq_float(v4_w(b), v4_w(a), 1.0f, 0.0f);
			float_to_bool(ND_add_float(cx, ND_add_float(cy, ND_add_float(cz, cw))))
		};

		)""");
	}

	ANALYZE(p_context, p_node_wrapper) {
		ComparisonType ctype = UNWRAP()->get_comparison_type();
		Function func = UNWRAP()->get_function();
		Condition cond = UNWRAP()->get_condition();
		const char* function_name = function_names[ctype][func][cond];
		
		if (ctype >= ComparisonType::CTYPE_MAX) {
			p_context.errors.push_back(std::format("VisualShaderNodeCompare: Unknown comparison type: {}", (uint32_t)ctype));
			return;
		}

		if (ctype == ComparisonType::CTYPE_TRANSFORM) {
			p_context.errors.push_back("VisualShaderNodeCompare: Transform comparison type is not supported");
			return;
		}

		if (func >= Function::FUNC_MAX) {
			p_context.errors.push_back(std::format("VisualShaderNodeCompare: Unknown function: {}", (uint32_t)func));
			return;
		}

		if (cond >= Condition::COND_MAX) {
			p_context.errors.push_back(std::format("VisualShaderNodeCompare: Unknown condition: {}", (uint32_t)cond));
			return;
		}

		if (!function_name) {
			p_context.errors.push_back(std::format("VisualShaderNodeCompare: Unsupported combination of type {}, function {}", (uint32_t)ctype, (uint32_t)func));
			return;
		}
	}

	EXPRESSION(p_context, p_node_wrapper) {
		ComparisonType ctype = UNWRAP()->get_comparison_type();
		Function func = UNWRAP()->get_function();
		Condition cond = UNWRAP()->get_condition();
		const char* function_name = function_names[ctype][func][cond];
		bool uses_tolerance = ctype == ComparisonType::CTYPE_SCALAR &&
		                      (func == Function::FUNC_EQUAL || func == Function::FUNC_NOT_EQUAL);
		if (uses_tolerance) {
			OUTPUT_EXPRESSION(0, std::format("{}({}, {}, {})", function_name, INPUT_EXPRESSION(0), INPUT_EXPRESSION(1), INPUT_EXPRESSION(2)));
		} else {
			OUTPUT_EXPRESSION(0, std::format("{}({}, {})", function_name, INPUT_EXPRESSION(0), INPUT_EXPRESSION(1)));
		}
	}
END(VisualShaderNodeCompare)
