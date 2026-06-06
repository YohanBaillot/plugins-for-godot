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
#include <godot_cpp/classes/visual_shader_node_fresnel.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeFresnel)
	static PortType input_port_types[4] = {
		PortType::VEC3F, // normal
		PortType::VEC3F, // view
		PortType::BOOL,  // inver
		PortType::FLOAT, // power
	};

	static std::string default_input_values[ShaderType::ST_COUNT][2];

	STATIC_INIT({
		default_input_values[ShaderType::ST_VERTEX][0] = sgl::builtin::vertex::normal();
		default_input_values[ShaderType::ST_VERTEX][1] = "UNREACHABLE";
		default_input_values[ShaderType::ST_FRAGMENT][0] = sgl::builtin::fragment::normal();
		default_input_values[ShaderType::ST_FRAGMENT][1] = sgl::builtin::fragment::view_vector();
	})
	
	INLET_COUNT(4)
	INPUT_TYPE_F(p_node_wrapper, p_index_param) {
		return input_port_types[p_index_param];
	}

	OUTPUT_TYPE(PortType::FLOAT)
	DEFAULT_INPUT_VALUE_F(p_node_param, p_index_param) {
		if (p_index_param < 2) {
			return default_input_values[p_node_param.shader_type][p_index_param];
		}
		return p_node_param.get_default_input_value_override(p_index_param);
	}

	DECLARATION(shader_type, p_context) {
		p_context.code_parts.push_back(R"""(

			let VisualShaderNodeFresnel_invert = { (normal, view, power) in
			  ND_power_float(ND_clamp_float(ND_dotproduct_vector3(normal, view), 0.0f, 1.0f), power)
			};
  
			let VisualShaderNodeFresnel_default = { (normal, view, power) in 
			  ND_power_float(ND_clamp_float(ND_subtract_float(1.0f, ND_dotproduct_vector3(normal, view)), 0.0f, 1.0f), power)
			};
  
			let VisualShaderNodeFresnel_conditional = { (normal, view, inverted, power) in 
				 let f = bool_to_float(inverted);
				 ND_ifequal_float(f, 1.0f, VisualShaderNodeFresnel_invert(normal, view, power), VisualShaderNodeFresnel_default(normal, view, power))
			};
			  
		)""");
	}

	EXPRESSION(p_context, p_node_wrapper) {
		std::string inverted_expression = INPUT_EXPRESSION(2);
		// Optimization, lookup the inverted parameter value and directly wire it to the proper node if it's a constant
		if (inverted_expression == "true") {
			OUTPUT_EXPRESSION(0, std::format("VisualShaderNodeFresnel_invert({}, {}, {})", INPUT_EXPRESSION(0), INPUT_EXPRESSION(1), INPUT_EXPRESSION(3)));
		} else if (inverted_expression == "false") {
			OUTPUT_EXPRESSION(0, std::format("VisualShaderNodeFresnel_default({}, {}, {})", INPUT_EXPRESSION(0), INPUT_EXPRESSION(1), INPUT_EXPRESSION(3)));
		} else {
			OUTPUT_EXPRESSION(0, std::format("VisualShaderNodeFresnel_conditional({}, {}, {}, {})", INPUT_EXPRESSION(0), INPUT_EXPRESSION(1), inverted_expression, INPUT_EXPRESSION(3)));
		}
	}
END(VisualShaderNodeFresnel)
