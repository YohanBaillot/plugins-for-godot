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
#include <godot_cpp/classes/visual_shader_node_multiply_add.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeMultiplyAdd)
	using OpType = godot::VisualShaderNodeMultiplyAdd::OpType;
	INLET_COUNT(3)

	static PortType type_map[OpType::OP_TYPE_MAX] = {};
	static const char* function_names[OpType::OP_TYPE_MAX] = {};
	STATIC_INIT({
		type_map[OpType::OP_TYPE_SCALAR] = PortType::FLOAT;
		type_map[OpType::OP_TYPE_VECTOR_2D] = PortType::VEC2F;
		type_map[OpType::OP_TYPE_VECTOR_3D] = PortType::VEC3F;
		type_map[OpType::OP_TYPE_VECTOR_4D] = PortType::VEC4F;
		
		function_names[OpType::OP_TYPE_SCALAR] = "VisualShaderNodeMultiplyAdd_float";
		function_names[OpType::OP_TYPE_VECTOR_2D] = "VisualShaderNodeMultiplyAdd_vec2";
		function_names[OpType::OP_TYPE_VECTOR_3D] = "VisualShaderNodeMultiplyAdd_vec3";
		function_names[OpType::OP_TYPE_VECTOR_4D] = "VisualShaderNodeMultiplyAdd_vec4";
	});

	PortType to_port_type(OpType p_type) {
		return type_map[p_type];
	}

	INPUT_TYPE_F(p_node_wrapper, p_index) {
		return type_map[UNWRAP()->get_op_type()];
	}
	OUTPUT_TYPE_F(p_node_wrapper) {
		return type_map[UNWRAP()->get_op_type()];
	}

	DECLARATION(p_shader_type, p_context) {
		p_context.code_parts.push_back(R"""(
			let VisualShaderNodeMultiplyAdd_float = { (a, b, c) in
				ND_add_float(ND_multiply_float(a, b), c)
			};
			let VisualShaderNodeMultiplyAdd_vec2 = { (a, b, c) in
				ND_add_vector2(ND_multiply_vector2(a, b), c)
			};
			let VisualShaderNodeMultiplyAdd_vec3 = { (a, b, c) in
				ND_add_vector3(ND_multiply_vector3(a, b), c)
			};  
			let VisualShaderNodeMultiplyAdd_vec4 = { (a, b, c) in
				ND_add_vector4(ND_multiply_vector4(a, b), c)
			};
		)""");
	}

	ANALYZE(p_context, p_node_wrapper) {
		OpType op = UNWRAP()->get_op_type();
		if (op > OpType::OP_TYPE_MAX) {
			p_context.errors.push_back(std::format("VisualShaderNodeMultiplyAdd: provided op value is invalid: {}", (uint32_t) op));
		}
	}

	EXPRESSION(p_context, p_node_wrapper) {
		OpType op = UNWRAP()->get_op_type();
		OUTPUT_EXPRESSION(0, std::format("{}({}, {}, {})", function_names[op], INPUT_EXPRESSION(0), INPUT_EXPRESSION(1), INPUT_EXPRESSION(2)));
	}
END(VisualShaderNodeMultiplyAdd)
