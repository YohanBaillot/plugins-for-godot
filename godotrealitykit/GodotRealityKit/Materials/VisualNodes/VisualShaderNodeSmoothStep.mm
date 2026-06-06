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
#include <godot_cpp/classes/visual_shader_node_smooth_step.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeSmoothStep)
	using OpType = godot::VisualShaderNodeSmoothStep::OpType;
	INLET_COUNT(3)

	static PortType output_type_map[OpType::OP_TYPE_MAX] = {};
	static PortType input_type_map[OpType::OP_TYPE_MAX][3] = {};
	static const char* function_names[OpType::OP_TYPE_MAX] = {};

	STATIC_INIT({
		output_type_map[OpType::OP_TYPE_SCALAR] = PortType::FLOAT;
		output_type_map[OpType::OP_TYPE_VECTOR_2D] = PortType::VEC2F;
		output_type_map[OpType::OP_TYPE_VECTOR_2D_SCALAR] = PortType::VEC2F;
		output_type_map[OpType::OP_TYPE_VECTOR_3D] = PortType::VEC3F;
		output_type_map[OpType::OP_TYPE_VECTOR_3D_SCALAR] = PortType::VEC3F;
		output_type_map[OpType::OP_TYPE_VECTOR_4D] = PortType::VEC4F;
		output_type_map[OpType::OP_TYPE_VECTOR_4D_SCALAR] = PortType::VEC4F;
		
		function_names[OpType::OP_TYPE_SCALAR] = "ND_smoothstep_float";
		function_names[OpType::OP_TYPE_VECTOR_2D] = "ND_smoothstep_vector2";
		function_names[OpType::OP_TYPE_VECTOR_2D_SCALAR] = "ND_smoothstep_vector2FA";
		function_names[OpType::OP_TYPE_VECTOR_3D] = "ND_smoothstep_vector3";
		function_names[OpType::OP_TYPE_VECTOR_3D_SCALAR] = "ND_smoothstep_vector3FA";
		function_names[OpType::OP_TYPE_VECTOR_4D] = "ND_smoothstep_vector4";
		function_names[OpType::OP_TYPE_VECTOR_4D_SCALAR] = "ND_smoothstep_vector4FA";
		
		input_type_map[OpType::OP_TYPE_SCALAR][0] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_SCALAR][1] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_SCALAR][2] = PortType::FLOAT;
		
		input_type_map[OpType::OP_TYPE_VECTOR_2D][0] = PortType::VEC2F;
		input_type_map[OpType::OP_TYPE_VECTOR_2D][1] = PortType::VEC2F;
		input_type_map[OpType::OP_TYPE_VECTOR_2D][2] = PortType::VEC2F;
		
		input_type_map[OpType::OP_TYPE_VECTOR_2D_SCALAR][0] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_VECTOR_2D_SCALAR][1] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_VECTOR_2D_SCALAR][2] = PortType::VEC2F;
		
		input_type_map[OpType::OP_TYPE_VECTOR_3D][0] = PortType::VEC3F;
		input_type_map[OpType::OP_TYPE_VECTOR_3D][1] = PortType::VEC3F;
		input_type_map[OpType::OP_TYPE_VECTOR_3D][2] = PortType::VEC3F;
		
		input_type_map[OpType::OP_TYPE_VECTOR_3D_SCALAR][0] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_VECTOR_3D_SCALAR][1] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_VECTOR_3D_SCALAR][2] = PortType::VEC3F;
		
		input_type_map[OpType::OP_TYPE_VECTOR_4D][0] = PortType::VEC4F;
		input_type_map[OpType::OP_TYPE_VECTOR_4D][1] = PortType::VEC4F;
		input_type_map[OpType::OP_TYPE_VECTOR_4D][2] = PortType::VEC4F;
		
		input_type_map[OpType::OP_TYPE_VECTOR_4D_SCALAR][0] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_VECTOR_4D_SCALAR][1] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_VECTOR_4D_SCALAR][2] = PortType::VEC4F;
	});

	INPUT_TYPE_F(p_node_wrapper, p_index) {
		return input_type_map[UNWRAP()->get_op_type()][p_index];
	}
	OUTPUT_TYPE_F(p_node_wrapper) {
		return output_type_map[UNWRAP()->get_op_type()];
	}

	ANALYZE(p_context, p_node_wrapper) {
		OpType op = UNWRAP()->get_op_type();
		if (op > OpType::OP_TYPE_MAX) {
			p_context.errors.push_back(std::format("VisualShaderNodeSmoothStep: provided op value is invalid: {}", (uint32_t) op));
		}
	}

	EXPRESSION(p_context, p_node_wrapper) {
		OpType op = UNWRAP()->get_op_type();
		OUTPUT_EXPRESSION(0, std::format("{}({}, {}, {})", function_names[op], INPUT_EXPRESSION(2),
																			   INPUT_EXPRESSION(0),
																			   INPUT_EXPRESSION(1)));
	}
END(VisualShaderNodeSmoothStep)
