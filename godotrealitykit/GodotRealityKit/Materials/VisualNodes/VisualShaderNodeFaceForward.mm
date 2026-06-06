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
#include "VisualShaderNodeVectorBase.h"
#include <godot_cpp/classes/visual_shader_node_face_forward.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeFaceForward)
	using OpType = godot::VisualShaderNodeVectorBase::OpType;
	INLET_COUNT(3)

	static const char *function_names[OpType::OP_TYPE_MAX] = { nullptr };
	STATIC_INIT({
		function_names[OpType::OP_TYPE_VECTOR_2D] = "VisualShaderNodeFaceForward_vec2";
		function_names[OpType::OP_TYPE_VECTOR_3D] = "VisualShaderNodeFaceForward_vec3";
		function_names[OpType::OP_TYPE_VECTOR_4D] = "VisualShaderNodeFaceForward_vec4";
	});

	ANALYZE(p_context, p_node_wrapper) {
		if (UNWRAP()->get_op_type() > godot::VisualShaderNodeVectorBase::OP_TYPE_MAX) {
			p_context.errors.push_back(std::format("VisualShaderNodeFaceForward: Invalid op type: {}", (uint32_t) UNWRAP()->get_op_type()));
		}
	}

	INPUT_TYPE_F(p_node_wrapper, p_index_param) {
		return gdrk::vs::to_port_type(UNWRAP()->get_op_type());
	}
	OUTPUT_TYPE_F(p_node_wrapper) {
		return gdrk::vs::to_port_type(UNWRAP()->get_op_type());
	}

	DECLARATION(p_shader_type, p_context) {
		p_context.code_parts.push_back(R"""(
			let VisualShaderNodeFaceForward_vec2 = { (v, i, ref) in
				let f = negate_float(ND_sign_float(ND_dotproduct_vector2(i, ref)));
				ND_multiply_vector2FA(v, f)
			};
  
			let VisualShaderNodeFaceForward_vec3 = { (v, i, ref) in
				let f = negate_float(ND_sign_float(ND_dotproduct_vector3(i, ref)));
				ND_multiply_vector3FA(v, f)
			};
  
			let VisualShaderNodeFaceForward_vec4 = { (v, i, ref) in
			  let f = negate_float(ND_sign_float(ND_dotproduct_vector4(i, ref)));
			  ND_multiply_vector4FA(v, f)
			};
		)""");
	}

	EXPRESSION(p_context, p_node_wrapper) {
		OpType op = UNWRAP()->get_op_type();
		
		const char* function_name = function_names[op];
		OUTPUT_EXPRESSION(0, std::format("{}({}, {}, {})", function_name, INPUT_EXPRESSION(0), INPUT_EXPRESSION(1), INPUT_EXPRESSION(2)));
	}
END(VisualShaderNodeFaceForward)
