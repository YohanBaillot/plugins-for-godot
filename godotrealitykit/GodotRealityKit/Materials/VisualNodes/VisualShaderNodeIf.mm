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
#include <godot_cpp/classes/visual_shader_node_if.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeIf)
	INLET_COUNT(6)

	static PortType output_type_map[6] = {
		PortType::FLOAT, // a
		PortType::FLOAT, // b
		PortType::FLOAT, // tolerance
		PortType::VEC3F, // if a == b
		PortType::VEC3F, // if a > b
		PortType::VEC3F, // if a < b
	};

	OUTPUT_TYPE(PortType::VEC3F);
	INPUT_TYPE_F(p_node_wrapper, p_port_index) {
		return output_type_map[p_port_index];
	}

	DECLARATION(p_shader_type, p_context) {
		p_context.code_parts.push_back(R"""(
			let VisualShaderNodeIf = { (a, b, tolerance, ifeq, ifgt, iflt) in
				let diff = ND_absval_float(ND_subtract_float(a, b));
				ND_ifgreater_vector3(tolerance, diff, ifeq, ND_ifgreater_vector3(a, b, ifgt, iflt))
			};
		)""");
	}

	EXPRESSION(p_context, p_node_wrapper) {
		OUTPUT_EXPRESSION(0, std::format("VisualShaderNodeIf({}, {}, {}, {}, {}, {})", INPUT_EXPRESSION(0),
																					   INPUT_EXPRESSION(1),
																					   INPUT_EXPRESSION(2),
																					   INPUT_EXPRESSION(3),
																					   INPUT_EXPRESSION(4),
																					   INPUT_EXPRESSION(5)));
	}
END(VisualShaderNodeIf)
