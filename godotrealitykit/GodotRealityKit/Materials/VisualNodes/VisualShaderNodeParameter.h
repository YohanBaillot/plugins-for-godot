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

#pragma once

#include "Supported.h"

// clang-format off
#define DECLARE_INPUT_PARAMETER_CLASS(ClassName, portType) \
	DEFINE_SUPPORTED_NODE(ClassName) \
		INLET_COUNT(0) \
		OUTPUT_TYPE(portType) \
\
 		DECLARE_UNIFORM(p_node, p_shader_type, p_node_index) { \
			godot::Variant value = NODE()->is_default_value_enabled() ? gdrk::to_port_value(portType, NODE()->get_default_value()) \
																	  : godot::Variant(false); \
			const godot::String param_name = NODE()->get_parameter_name(); \
			return UniformDescriptor { \
				.name = param_name, \
				.type = portType, \
				.default_value = value, \
			}; \
		} \
\
		EXPRESSION(p_context, p_node_wrapper) { \
			const godot::String param_name = UNWRAP()->get_parameter_name(); \
			OUTPUT_EXPRESSION(0, gdrk::to_std_string(param_name)); \
		} \
	END(ClassName) \

