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
#include <godot_cpp/classes/visual_shader_node_color_func.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeColorFunc)
	INLET_COUNT(1)
	OUTPUT_TYPE(PortType::VEC3F)
	INPUT_TYPE(PortType::VEC3F)

	using Function = godot::VisualShaderNodeColorFunc::Function;
	static const char* function_names[Function::FUNC_MAX] = { nullptr };
	STATIC_INIT({
		function_names[Function::FUNC_GRAYSCALE] = "VisualShaderNodeColorFunc_grayscale";
		function_names[Function::FUNC_HSV2RGB] = "VisualShaderNodeColorFunc_hsvtorgb";
		function_names[Function::FUNC_RGB2HSV] = "VisualShaderNodeColorFunc_rgbtohsv";
		function_names[Function::FUNC_SEPIA] = "VisualShaderNodeColorFunc_sepia";
		function_names[Function::FUNC_LINEAR_TO_SRGB] = "VisualShaderNodeColorFunc_linear_to_srgb";
		function_names[Function::FUNC_SRGB_TO_LINEAR] = "VisualShaderNodeColorFunc_srgb_to_linear";
	})

	DECLARATION(p_shader_type, p_context) {
		p_context.code_parts.push_back(R"""(
			let VisualShaderNodeColorFunc_grayscale = { (c) in
				let max1 = ND_max_float(v3_x(c), v3_y(c));
				let max2 = ND_max_float(max1, v3_z(c));
				ND_combine3_vector3(max2, max2, max2)
			};
  
			let VisualShaderNodeColorFunc_hsvtorgb = { (c) in
				rgb_to_vec3f(ND_hsvtorgb_color3(vec3f_to_rgb(c)))
			};
  
			  let VisualShaderNodeColorFunc_rgbtohsv = { (c) in
				rgb_to_vec3f(ND_rgbtohsv_color3(vec3f_to_rgb(c)))
			  };

			let VisualShaderNodeColorFunc_sepia = { (c) in
				let r1 = ND_multiply_float(v3_x(c), 0.393f);
				let r2 = ND_multiply_float(v3_y(c), 0.769f);
				let r3 = ND_multiply_float(v3_z(c), 0.189f);
				let r = ND_add_float(ND_add_float(r1, r2), r3);

				let g1 = ND_multiply_float(v3_x(c), 0.349f);
				let g2 = ND_multiply_float(v3_y(c), 0.686f);
				let g3 = ND_multiply_float(v3_z(c), 0.168f);
				let g = ND_add_float(ND_add_float(g1, g2), g3);

				let b1 = ND_multiply_float(v3_x(c), 0.272f);
				let b2 = ND_multiply_float(v3_y(c), 0.534f);
				let b3 = ND_multiply_float(v3_z(c), 0.131f);
				let b = ND_add_float(ND_add_float(b1, b2), b3);
				ND_combine3_vector3(r, g, b)
			};

			let VisualShaderNodeColorFunc_linear_to_srgb = { (c) in
				linear_to_srgb(c)
			};

			let VisualShaderNodeColorFunc_srgb_to_linear = { (c) in
				srgb_to_linear(c)
			};
		)""");
	}

	EXPRESSION(p_context, p_node_wrapper) {
		godot::VisualShaderNodeColorFunc *node = (godot::VisualShaderNodeColorFunc *) p_node_wrapper.node;
		Function func = node->get_function();

		if (func >= Function::FUNC_MAX) {
			p_context.errors.push_back(std::format("godot::VisualShaderNodeColorFunc: Unknown function: {}", (uint32_t) func));
			return;
		}

		const char* function_name = function_names[func];
		if (!function_name) {
			p_context.errors.push_back(std::format("godot::VisualShaderNodeColorFunc: Unsupported function: {}", (uint32_t) func));
			return;
		}

		OUTPUT_EXPRESSION(0, std::format("{}({})", function_name, INPUT_EXPRESSION(0)));
	}
END(VisualShaderNodeColorFunc)
