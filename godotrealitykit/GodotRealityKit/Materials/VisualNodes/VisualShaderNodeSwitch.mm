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
#include <godot_cpp/classes/visual_shader_node_switch.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeSwitch)
	using OpType = godot::VisualShaderNodeSwitch::OpType;
	
	static PortType io_port_types[OpType::OP_TYPE_MAX] = { PortType::UNDEFINED };
	static const char *function_names[OpType::OP_TYPE_MAX] = { nullptr };
	STATIC_INIT({
		io_port_types[OpType::OP_TYPE_FLOAT] = PortType::FLOAT;
		io_port_types[OpType::OP_TYPE_INT] = PortType::INT;
		io_port_types[OpType::OP_TYPE_UINT] = PortType::UINT;
		io_port_types[OpType::OP_TYPE_VECTOR_2D] = PortType::VEC2F;
		io_port_types[OpType::OP_TYPE_VECTOR_3D] = PortType::VEC3F;
		io_port_types[OpType::OP_TYPE_VECTOR_4D] = PortType::VEC4F;
		io_port_types[OpType::OP_TYPE_BOOLEAN] = PortType::BOOL;
		io_port_types[OpType::OP_TYPE_TRANSFORM] = PortType::TRANSFORM3D;
		
		function_names[OpType::OP_TYPE_FLOAT] = "VisualShaderNodeSwitch_float";
		function_names[OpType::OP_TYPE_INT] = "VisualShaderNodeSwitch_int";
		function_names[OpType::OP_TYPE_UINT] = "VisualShaderNodeSwitch_uint";
		function_names[OpType::OP_TYPE_VECTOR_2D] = "VisualShaderNodeSwitch_vector2d";
		function_names[OpType::OP_TYPE_VECTOR_3D] = "VisualShaderNodeSwitch_vector3d";
		function_names[OpType::OP_TYPE_VECTOR_4D] = "VisualShaderNodeSwitch_vector4d";
		function_names[OpType::OP_TYPE_BOOLEAN] = "VisualShaderNodeSwitch_boolean";
		function_names[OpType::OP_TYPE_TRANSFORM] = "VisualShaderNodeSwitch_transform";
	});

	INLET_COUNT(3)

	OUTPUT_TYPE_F(p_node_wrapper) {
		return	io_port_types[UNWRAP()->get_op_type()];
	}
	INPUT_TYPE_F(p_node_wrapper, p_port_index) {
		return p_port_index == 0 ? PortType::BOOL : io_port_types[UNWRAP()->get_op_type()];
	}

	DECLARATION(p_shader_type, p_context) {
		
		p_context.code_parts.push_back(R"""(
			let VisualShaderNodeSwitch_float = { (condition, t_val, f_val)in
				ND_ifequal_floatI(condition, 1, t_val, f_val)
			};
			let VisualShaderNodeSwitch_int = { (condition, t_val, f_val)in
				let t_val_f = int_to_float(t_val);
				let f_val_f = int_to_float(f_val);
				let res_f = ND_ifequal_floatI(condition, 1, t_val_f, f_val_f);
				float_to_int(res_f)
			};
			let VisualShaderNodeSwitch_uint = { (condition, t_val, f_val)in
				unimplemented()
			};
			let VisualShaderNodeSwitch_vector2d = { (condition, t_val, f_val)in
				ND_ifequal_vector2I(condition, 1, t_val, f_val)
			};
			let VisualShaderNodeSwitch_vector3d = { (condition, t_val, f_val)in
				ND_ifequal_vector3I(condition, 1, t_val, f_val)
			};
			let VisualShaderNodeSwitch_vector4d = { (condition, t_val, f_val)in
				ND_ifequal_vector4I(condition, 1, t_val, f_val)
			};
			let VisualShaderNodeSwitch_boolean = { (condition, t_val, f_val)in
				let t_val_f = bool_to_half(t_val);
				let f_val_f = bool_to_half(f_val);
				let res_f = ND_ifequal_halfI(condition, 1, t_val_f, f_val_f);
				half_to_bool(res_f)
			};
			let VisualShaderNodeSwitch_transform = { (condition, t_val, f_val)in
				unimplemented()
			};
		)""");
	}

	EXPRESSION(p_context, p_node_wrapper) {
		OpType op = UNWRAP()->get_op_type();
		if (op > OpType::OP_TYPE_MAX) {
			p_context.errors.push_back(std::format("godot::VisualShaderNodeSwitch: Unknown OpType: {}", (uint32_t) op));
			return;
		}
		
		const char* function_name = function_names[op];
		if (!function_name) {
			p_context.errors.push_back(std::format("godot::VisualShaderNodeSwitch: Unsupported OpType: {}", (uint32_t) op));
			return;
		}

		OUTPUT_EXPRESSION(0, std::format("{}({}, {}, {})", function_name, INPUT_EXPRESSION(0), INPUT_EXPRESSION(1), INPUT_EXPRESSION(2)));
	}
END(VisualShaderNodeSwitch)
