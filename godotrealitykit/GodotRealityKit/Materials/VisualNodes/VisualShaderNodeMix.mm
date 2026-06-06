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
#include <godot_cpp/classes/visual_shader_node_mix.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeMix)
	using OpType = godot::VisualShaderNodeMix::OpType;
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

		function_names[OpType::OP_TYPE_SCALAR] = "ND_mix_float";
		function_names[OpType::OP_TYPE_VECTOR_2D] = "VisualShaderNodeMix_vector2";
		function_names[OpType::OP_TYPE_VECTOR_2D_SCALAR] = "ND_mix_vector2";
		function_names[OpType::OP_TYPE_VECTOR_3D] = "VisualShaderNodeMix_vector3";
		function_names[OpType::OP_TYPE_VECTOR_3D_SCALAR] = "ND_mix_vector3";
		function_names[OpType::OP_TYPE_VECTOR_4D] = "VisualShaderNodeMix_vector4";
		function_names[OpType::OP_TYPE_VECTOR_4D_SCALAR] = "ND_mix_vector4";

		input_type_map[OpType::OP_TYPE_SCALAR][0] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_SCALAR][1] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_SCALAR][2] = PortType::FLOAT;

		input_type_map[OpType::OP_TYPE_VECTOR_2D][0] = PortType::VEC2F;
		input_type_map[OpType::OP_TYPE_VECTOR_2D][1] = PortType::VEC2F;
		input_type_map[OpType::OP_TYPE_VECTOR_2D][2] = PortType::VEC2F;

		input_type_map[OpType::OP_TYPE_VECTOR_2D_SCALAR][0] = PortType::VEC2F;
		input_type_map[OpType::OP_TYPE_VECTOR_2D_SCALAR][1] = PortType::VEC2F;
		input_type_map[OpType::OP_TYPE_VECTOR_2D_SCALAR][2] = PortType::FLOAT;

		input_type_map[OpType::OP_TYPE_VECTOR_3D][0] = PortType::VEC3F;
		input_type_map[OpType::OP_TYPE_VECTOR_3D][1] = PortType::VEC3F;
		input_type_map[OpType::OP_TYPE_VECTOR_3D][2] = PortType::VEC3F;

		input_type_map[OpType::OP_TYPE_VECTOR_3D_SCALAR][0] = PortType::VEC3F;
		input_type_map[OpType::OP_TYPE_VECTOR_3D_SCALAR][1] = PortType::VEC3F;
		input_type_map[OpType::OP_TYPE_VECTOR_3D_SCALAR][2] = PortType::FLOAT;

		input_type_map[OpType::OP_TYPE_VECTOR_4D][0] = PortType::VEC4F;
		input_type_map[OpType::OP_TYPE_VECTOR_4D][1] = PortType::VEC4F;
		input_type_map[OpType::OP_TYPE_VECTOR_4D][2] = PortType::VEC4F;

		input_type_map[OpType::OP_TYPE_VECTOR_4D_SCALAR][0] = PortType::VEC4F;
		input_type_map[OpType::OP_TYPE_VECTOR_4D_SCALAR][1] = PortType::VEC4F;
		input_type_map[OpType::OP_TYPE_VECTOR_4D_SCALAR][2] = PortType::FLOAT;
	});

	INPUT_TYPE_F(p_node_wrapper, p_index) {
		return input_type_map[UNWRAP()->get_op_type()][p_index];
	}
	OUTPUT_TYPE_F(p_node_wrapper) {
		return output_type_map[UNWRAP()->get_op_type()];
	}

	DECLARATION(p_shader_type, p_context) {
		p_context.code_parts.push_back(R"""(
			let VisualShaderNodeMix_vector2 = { (a, b, weight) in
				ND_combine2_vector2(ND_mix_float(v2_x(a), v2_x(b), v2_x(weight)), ND_mix_float(v2_y(a), v2_y(b), v2_y(weight)))
			};
			let VisualShaderNodeMix_vector3 = { (a, b, weight) in
				ND_combine3_vector3(ND_mix_float(v3_x(a), v3_x(b), v3_x(weight)), ND_mix_float(v3_y(a), v3_y(b), v3_y(weight)), ND_mix_float(v3_z(a), v3_z(b), v3_z(weight)))
			};
			let VisualShaderNodeMix_vector4 = { (a, b, weight) in
				ND_combine4_vector4(ND_mix_float(v4_x(a), v4_x(b), v4_x(weight)), ND_mix_float(v4_y(a), v4_y(b), v4_y(weight)), ND_mix_float(v4_z(a), v4_z(b), v4_z(weight)), ND_mix_float(v4_w(a), v4_w(b), v4_w(weight)))
			};
		)""");
	}

	ANALYZE(p_context, p_node_wrapper) {
		OpType op = UNWRAP()->get_op_type();
		if (op >= OpType::OP_TYPE_MAX) {
			p_context.errors.push_back(std::format("VisualShaderNodeMix: provided op value is invalid: {}", (uint32_t) op));
		}
	}

	EXPRESSION(p_context, p_node_wrapper) {
		OpType op = UNWRAP()->get_op_type();
		OUTPUT_EXPRESSION(0, std::format("{}({}, {}, {})", function_names[op], INPUT_EXPRESSION(1), INPUT_EXPRESSION(0), INPUT_EXPRESSION(2)));
	}
END(VisualShaderNodeMix)
