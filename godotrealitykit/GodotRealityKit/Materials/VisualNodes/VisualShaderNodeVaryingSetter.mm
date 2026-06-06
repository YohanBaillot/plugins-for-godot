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
#include "VisualShaderNodeVarying.h"
#include <godot_cpp/classes/visual_shader_node_varying_setter.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeVaryingSetter)
	INLET_COUNT(1)
	INPUT_TYPE_F(p_node_wrapper, p_index) {
		return vs::to_port_type(UNWRAP()->get_varying_type());
	}
	EXPRESSION(p_context, p_node_wrapper) {
		VaryingAllocator &vallocator = p_context.varying_allocator;
		godot::VisualShader::VaryingType vtype = UNWRAP()->get_varying_type();
		
		godot::String name = UNWRAP()->get_varying_name();
		const gdrk::VaryingAllocator::VaryingDescriptor *varying = vallocator.get_varying(name);
		if (!varying) {
			p_context.warnings.push_back(std::format("VisualShaderNodeVaryingSetter: '{}' was not allocated. This is likely due to the varying not being used in the fragment shader.", to_std_string(name)));
			return;
		}
		
		vallocator.assign_varying_slot_names(*varying);
		
		std::string output_var_name = p_node_wrapper.get_output_var_name(p_context, 0);
		if (varying->type == PortType::BOOL) {
			ERR_FAIL_COND_MSG(varying->slot_count != 1, "VisualShaderNodeVaryingSetter: Unexpected slot count returned for type BOOL");
			p_context.code_parts.push_back(sgl::statement::let(vallocator.get_vertex_slot_var_name(*varying, 0), INPUT_EXPRESSION(0)));
		} else if (varying->type == PortType::INT) {
			ERR_FAIL_COND_MSG(varying->slot_count != 1, "VisualShaderNodeVaryingSetter: Unexpected slot count returned for type INT");
			p_context.code_parts.push_back(sgl::statement::let(vallocator.get_vertex_slot_var_name(*varying, 0), INPUT_EXPRESSION(0)));
		} else if (varying->type == PortType::UINT) {
			ERR_FAIL_COND_MSG(varying->slot_count != 1, "VisualShaderNodeVaryingSetter: Unexpected slot count returned for type UINT");
			p_context.code_parts.push_back(sgl::statement::let(vallocator.get_vertex_slot_var_name(*varying, 0), INPUT_EXPRESSION(0)));
		} else if (varying->type == PortType::FLOAT) {
			ERR_FAIL_COND_MSG(varying->slot_count != 1, "VisualShaderNodeVaryingSetter: Unexpected slot count returned for type FLOAT");
			p_context.code_parts.push_back(sgl::statement::let(vallocator.get_vertex_slot_var_name(*varying, 0), INPUT_EXPRESSION(0)));
		} else if (varying->type == PortType::VEC2F) {
			ERR_FAIL_COND_MSG(varying->slot_count != 2, "VisualShaderNodeVaryingSetter: Unexpected slot count returned for type VEC2F");
			p_context.code_parts.push_back(sgl::statement::let(vallocator.get_vertex_slot_var_name(*varying, 0), std::format("v2_x({})", INPUT_EXPRESSION(0))));
			p_context.code_parts.push_back(sgl::statement::let(vallocator.get_vertex_slot_var_name(*varying, 1), std::format("v2_y({})", INPUT_EXPRESSION(0))));
		} else if (varying->type == PortType::VEC3F) {
			ERR_FAIL_COND_MSG(varying->slot_count != 3, "VisualShaderNodeVaryingSetter: Unexpected slot count returned for type VEC3F");
			p_context.code_parts.push_back(sgl::statement::let(vallocator.get_vertex_slot_var_name(*varying, 0), std::format("v3_x({})", INPUT_EXPRESSION(0))));
			p_context.code_parts.push_back(sgl::statement::let(vallocator.get_vertex_slot_var_name(*varying, 1), std::format("v3_y({})", INPUT_EXPRESSION(0))));
			p_context.code_parts.push_back(sgl::statement::let(vallocator.get_vertex_slot_var_name(*varying, 2), std::format("v3_z({})", INPUT_EXPRESSION(0))));
		}  else if (varying->type == PortType::VEC4F) {
			ERR_FAIL_COND_MSG(varying->slot_count != 4, "VisualShaderNodeVaryingSetter: Unexpected slot count returned for type VEC3F");
			p_context.code_parts.push_back(sgl::statement::let(vallocator.get_vertex_slot_var_name(*varying, 0), std::format("v4_x({})", INPUT_EXPRESSION(0))));
			p_context.code_parts.push_back(sgl::statement::let(vallocator.get_vertex_slot_var_name(*varying, 1), std::format("v4_y({})", INPUT_EXPRESSION(0))));
			p_context.code_parts.push_back(sgl::statement::let(vallocator.get_vertex_slot_var_name(*varying, 2), std::format("v4_z({})", INPUT_EXPRESSION(0))));
			p_context.code_parts.push_back(sgl::statement::let(vallocator.get_vertex_slot_var_name(*varying, 3), std::format("v4_w({})", INPUT_EXPRESSION(0))));
		} else {
			p_context.errors.push_back(std::format("VisualShaderNodeVaryingSetter: Unsupported Godot varying type: {}", (uint32_t) vtype));
		}
	}
END(VisualShaderNodeVaryingSetter)
