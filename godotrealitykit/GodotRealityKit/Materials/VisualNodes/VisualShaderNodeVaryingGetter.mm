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
#include <godot_cpp/classes/visual_shader_node_varying_getter.hpp>

#include <format>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeVaryingGetter)
	INLET_COUNT(0)
	OUTPUT_TYPE_F(p_node_wrapper) {
		return vs::to_port_type(UNWRAP()->get_varying_type());
	}
	EXPRESSION(p_context, p_node_wrapper) {
		godot::VisualShader::VaryingType vtype = UNWRAP()->get_varying_type();
		godot::String name = UNWRAP()->get_varying_name();
		const gdrk::VaryingAllocator::VaryingDescriptor *varying = p_context.varying_allocator.get_varying(name);
		
		if (!varying) {
			p_context.errors.push_back(std::format("VisualShaderNodeVaryingGetter: '{}' was not allocated. This is likely due to an earlier error.", to_std_string(name)));
			return;
		}
		
		std::optional<std::string> expression = p_context.varying_allocator.get_fragment_expression_for_varying(*varying);
		if (expression == std::nullopt) {
			p_context.errors.push_back(std::format("VisualShaderNodeVaryingGetter: Unsupported Godot varying type: {}", (uint32_t) vtype));
			return;
		}
		
		OUTPUT_EXPRESSION(0, *expression);
	}
END(VisualShaderNodeVaryingGetter)
