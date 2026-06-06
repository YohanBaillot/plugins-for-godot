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
#include <godot_cpp/classes/visual_shader_node_vector_len.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeVectorLen)
	using OpType = godot::VisualShaderNodeVectorBase::OpType;
	
	static PortType io_port_types[OpType::OP_TYPE_MAX] = { PortType::UNDEFINED };
	static const char *function_names[OpType::OP_TYPE_MAX] = { nullptr };
	
	STATIC_INIT({
		io_port_types[OpType::OP_TYPE_VECTOR_2D] = PortType::VEC2F;
		io_port_types[OpType::OP_TYPE_VECTOR_3D] = PortType::VEC3F;
		io_port_types[OpType::OP_TYPE_VECTOR_4D] = PortType::VEC4F;
		
		function_names[OpType::OP_TYPE_VECTOR_2D] = "ND_magnitude_vector2";
		function_names[OpType::OP_TYPE_VECTOR_3D] = "ND_magnitude_vector3";
		function_names[OpType::OP_TYPE_VECTOR_4D] = "ND_magnitude_vector4";
	});

	INLET_COUNT(2)

	OUTPUT_TYPE(PortType::FLOAT)
	INPUT_TYPE_F(p_node_wrapper, p_port_index) {
		return io_port_types[UNWRAP()->get_op_type()];
	}

	ANALYZE(p_context, p_node_wrapper) {
		OpType op = UNWRAP()->get_op_type();
		if (op > OpType::OP_TYPE_MAX) {
			p_context.errors.push_back(std::format("godot::VisualShaderNodeClamp: Unknown OpType: {}", (uint32_t) op));
		}
	}

	EXPRESSION(p_context, p_node_wrapper) {
		OpType op = UNWRAP()->get_op_type();
		OUTPUT_EXPRESSION(0, std::format("{}({})", function_names[op], INPUT_EXPRESSION(0)));
	}
END(VisualShaderNodeVectorLen)
