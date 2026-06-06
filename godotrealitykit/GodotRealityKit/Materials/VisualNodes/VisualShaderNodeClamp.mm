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
#include <godot_cpp/classes/visual_shader_node_clamp.hpp>

#include <format>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeClamp)
	using OpType = godot::VisualShaderNodeClamp::OpType;
	
	static PortType io_port_types[OpType::OP_TYPE_MAX] = { PortType::UNDEFINED };
	static const char *function_names[OpType::OP_TYPE_MAX] = { nullptr };
	
	STATIC_INIT({
		io_port_types[OpType::OP_TYPE_FLOAT] = PortType::FLOAT;
		io_port_types[OpType::OP_TYPE_INT] = PortType::INT;
		io_port_types[OpType::OP_TYPE_UINT] = PortType::UINT;
		io_port_types[OpType::OP_TYPE_VECTOR_2D] = PortType::VEC2F;
		io_port_types[OpType::OP_TYPE_VECTOR_3D] = PortType::VEC3F;
		io_port_types[OpType::OP_TYPE_VECTOR_4D] = PortType::VEC4F;
		
		function_names[OpType::OP_TYPE_FLOAT] = "ND_clamp_float";
		function_names[OpType::OP_TYPE_INT] = "VisualShaderNodeClamp_integer";
		function_names[OpType::OP_TYPE_UINT] = "unimplemented";
		function_names[OpType::OP_TYPE_VECTOR_2D] = "ND_clamp_vector2";
		function_names[OpType::OP_TYPE_VECTOR_3D] = "ND_clamp_vector3";
		function_names[OpType::OP_TYPE_VECTOR_4D] = "ND_clamp_vector4";
	});

	INLET_COUNT(3)

	OUTPUT_TYPE_F(p_node_wrapper) {
		return io_port_types[UNWRAP()->get_op_type()];
	}
	INPUT_TYPE_F(p_node_wrapper, p_port_index) {
		return io_port_types[UNWRAP()->get_op_type()];
	}

	DECLARATION(p_shader_type, p_context) {
		p_context.code_parts.push_back(R"""(
			let VisualShaderNodeClamp_integer = { (v, min_v, max_v) in
				float_to_int(ND_clamp_float(int_to_float(v), int_to_float(min_v), int_to_float(max_v)))
			};
		)""");
	}

	EXPRESSION(p_context, p_node_wrapper) {
		OpType op = UNWRAP()->get_op_type();
		if (op > OpType::OP_TYPE_MAX) {
			p_context.errors.push_back(std::format("godot::VisualShaderNodeClamp: Unknown OpType: {}", (uint32_t) op));
			return;
		}
		
		const char* function_name = function_names[op];
		if (!function_name) {
			p_context.errors.push_back(std::format("godot::VisualShaderNodeClamp: Unsupported OpType: {}", (uint32_t) op));
			return;
		}
		
		OUTPUT_EXPRESSION(0, std::format("{}({}, {}, {})", function_name, INPUT_EXPRESSION(0), INPUT_EXPRESSION(1), INPUT_EXPRESSION(2)));
	}
END(VisualShaderNodeClamp)
