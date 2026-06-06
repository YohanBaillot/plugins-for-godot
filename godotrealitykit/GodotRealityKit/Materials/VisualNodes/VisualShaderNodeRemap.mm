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
#include <godot_cpp/classes/visual_shader_node_remap.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeRemap)
	using OpType = godot::VisualShaderNodeRemap::OpType;
	INLET_COUNT(5)

	static PortType output_type_map[OpType::OP_TYPE_MAX] = {};
	static PortType input_type_map[OpType::OP_TYPE_MAX][5] = {};
	static const char* function_names[OpType::OP_TYPE_MAX] = {};

	STATIC_INIT({
		output_type_map[OpType::OP_TYPE_SCALAR] = PortType::FLOAT;
		output_type_map[OpType::OP_TYPE_VECTOR_2D] = PortType::VEC2F;
		output_type_map[OpType::OP_TYPE_VECTOR_2D_SCALAR] = PortType::VEC2F;
		output_type_map[OpType::OP_TYPE_VECTOR_3D] = PortType::VEC3F;
		output_type_map[OpType::OP_TYPE_VECTOR_3D_SCALAR] = PortType::VEC3F;
		output_type_map[OpType::OP_TYPE_VECTOR_4D] = PortType::VEC4F;
		output_type_map[OpType::OP_TYPE_VECTOR_4D_SCALAR] = PortType::VEC4F;
		
		function_names[OpType::OP_TYPE_SCALAR] = "VisualShaderNodeRemap_float";
		function_names[OpType::OP_TYPE_VECTOR_2D] = "VisualShaderNodeRemap_vec2";
		function_names[OpType::OP_TYPE_VECTOR_2D_SCALAR] = "VisualShaderNodeRemap_vec2_scalar";
		function_names[OpType::OP_TYPE_VECTOR_3D] = "VisualShaderNodeRemap_vec3";
		function_names[OpType::OP_TYPE_VECTOR_3D_SCALAR] = "VisualShaderNodeRemap_vec3_scalar";
		function_names[OpType::OP_TYPE_VECTOR_4D] = "VisualShaderNodeRemap_vec4";
		function_names[OpType::OP_TYPE_VECTOR_4D_SCALAR] = "VisualShaderNodeRemap_vec4_scalar";
		
		input_type_map[OpType::OP_TYPE_SCALAR][0] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_SCALAR][1] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_SCALAR][2] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_SCALAR][3] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_SCALAR][4] = PortType::FLOAT;
		
		input_type_map[OpType::OP_TYPE_VECTOR_2D][0] = PortType::VEC2F;
		input_type_map[OpType::OP_TYPE_VECTOR_2D][1] = PortType::VEC2F;
		input_type_map[OpType::OP_TYPE_VECTOR_2D][2] = PortType::VEC2F;
		input_type_map[OpType::OP_TYPE_VECTOR_2D][3] = PortType::VEC2F;
		input_type_map[OpType::OP_TYPE_VECTOR_2D][4] = PortType::VEC2F;
		
		input_type_map[OpType::OP_TYPE_VECTOR_2D_SCALAR][0] = PortType::VEC2F;
		input_type_map[OpType::OP_TYPE_VECTOR_2D_SCALAR][1] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_VECTOR_2D_SCALAR][2] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_VECTOR_2D_SCALAR][3] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_VECTOR_2D_SCALAR][4] = PortType::FLOAT;
		
		input_type_map[OpType::OP_TYPE_VECTOR_3D][0] = PortType::VEC3F;
		input_type_map[OpType::OP_TYPE_VECTOR_3D][1] = PortType::VEC3F;
		input_type_map[OpType::OP_TYPE_VECTOR_3D][2] = PortType::VEC3F;
		input_type_map[OpType::OP_TYPE_VECTOR_3D][3] = PortType::VEC3F;
		input_type_map[OpType::OP_TYPE_VECTOR_3D][4] = PortType::VEC3F;
		
		input_type_map[OpType::OP_TYPE_VECTOR_3D_SCALAR][0] = PortType::VEC3F;
		input_type_map[OpType::OP_TYPE_VECTOR_3D_SCALAR][1] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_VECTOR_3D_SCALAR][2] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_VECTOR_3D_SCALAR][3] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_VECTOR_3D_SCALAR][4] = PortType::FLOAT;
		
		input_type_map[OpType::OP_TYPE_VECTOR_4D][0] = PortType::VEC4F;
		input_type_map[OpType::OP_TYPE_VECTOR_4D][1] = PortType::VEC4F;
		input_type_map[OpType::OP_TYPE_VECTOR_4D][2] = PortType::VEC4F;
		input_type_map[OpType::OP_TYPE_VECTOR_4D][3] = PortType::VEC4F;
		input_type_map[OpType::OP_TYPE_VECTOR_4D][4] = PortType::VEC4F;
		
		input_type_map[OpType::OP_TYPE_VECTOR_4D_SCALAR][0] = PortType::VEC4F;
		input_type_map[OpType::OP_TYPE_VECTOR_4D_SCALAR][1] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_VECTOR_4D_SCALAR][2] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_VECTOR_4D_SCALAR][3] = PortType::FLOAT;
		input_type_map[OpType::OP_TYPE_VECTOR_4D_SCALAR][4] = PortType::FLOAT;
	});

	INPUT_TYPE_F(p_node_wrapper, p_index) {
		return input_type_map[UNWRAP()->get_op_type()][p_index];
	}
	OUTPUT_TYPE_F(p_node_wrapper) {
		return output_type_map[UNWRAP()->get_op_type()];
	}

	DECLARATION(p_shader_type, p_context) {
		p_context.code_parts.push_back(R"""(
			let VisualShaderNodeRemap_float = { (a, minIn, maxIn, minOut, maxOut) in
				let inRange = ND_subtract_float(maxIn, minIn);
				let outRange = ND_subtract_float(maxOut, minOut);
				let normalizedIn = ND_divide_float(ND_subtract_float(a, minIn), inRange);
				ND_add_float(ND_multiply_float(normalizedIn, outRange), minOut)
			};
			let VisualShaderNodeRemap_vec2 = { (a, minIn, maxIn, minOut, maxOut) in
				let inRange = ND_subtract_vector2(maxIn, minIn);
				let outRange = ND_subtract_vector2(maxOut, minOut);
				let normalizedIn = ND_divide_vector2(ND_subtract_vector2(a, minIn), inRange);
				ND_add_vector2(ND_multiply_vector2(normalizedIn, outRange), minOut)
			};
			let VisualShaderNodeRemap_vec3 = { (a, minIn, maxIn, minOut, maxOut) in
				let inRange = ND_subtract_vector3(maxIn, minIn);
				let outRange = ND_subtract_vector3(maxOut, minOut);
				let normalizedIn = ND_divide_vector3(ND_subtract_vector3(a, minIn), inRange);
				ND_add_vector3(ND_multiply_vector3(normalizedIn, outRange), minOut)
			};
			let VisualShaderNodeRemap_vec4 = { (a, minIn, maxIn, minOut, maxOut) in
				let inRange = ND_subtract_vector4(maxIn, minIn);
				let outRange = ND_subtract_vector4(maxOut, minOut);
				let normalizedIn = ND_divide_vector4(ND_subtract_vector4(a, minIn), inRange);
				ND_add_vector4(ND_multiply_vector4(normalizedIn, outRange), minOut)
			};
			let VisualShaderNodeRemap_vec2_scalar = { (a, minIn, maxIn, minOut, maxOut) in
				let inRange = ND_subtract_float(maxIn, minIn);
				let outRange = ND_subtract_float(maxOut, minOut);
				let normalizedIn = ND_divide_vector2FA(ND_subtract_vector2FA(a, minIn), inRange);
				ND_add_vector2FA(ND_multiply_vector2FA(normalizedIn, outRange), minOut)
			};
			let VisualShaderNodeRemap_vec3_scalar = { (a, minIn, maxIn, minOut, maxOut) in
			   let inRange = ND_subtract_float(maxIn, minIn);
			   let outRange = ND_subtract_float(maxOut, minOut);
			   let normalizedIn = ND_divide_vector3FA(ND_subtract_vector3FA(a, minIn), inRange);
			   ND_add_vector3FA(ND_multiply_vector3FA(normalizedIn, outRange), minOut)
			};
			let VisualShaderNodeRemap_vec4_scalar = { (a, minIn, maxIn, minOut, maxOut) in
			  let inRange = ND_subtract_float(maxIn, minIn);
			  let outRange = ND_subtract_float(maxOut, minOut);
			  let normalizedIn = ND_divide_vector4FA(ND_subtract_vector4FA(a, minIn), inRange);
			  ND_add_vector4FA(ND_multiply_vector4FA(normalizedIn, outRange), minOut)
			};
		)""");
	}

	ANALYZE(p_context, p_node_wrapper) {
		OpType op = UNWRAP()->get_op_type();
		if (op > OpType::OP_TYPE_MAX) {
			p_context.errors.push_back(std::format("VisualShaderNodeRemap: provided op value is invalid: {}", (uint32_t) op));
		}
	}

	EXPRESSION(p_context, p_node_wrapper) {
		OpType op = UNWRAP()->get_op_type();
		OUTPUT_EXPRESSION(0, std::format("{}({}, {}, {}, {}, {})", function_names[op], INPUT_EXPRESSION(0),
																					   INPUT_EXPRESSION(1),
																					   INPUT_EXPRESSION(2),
																					   INPUT_EXPRESSION(3),
																					   INPUT_EXPRESSION(4)));
	}
END(VisualShaderNodeRemap)
