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

#include "../material_bridge.h"
#include <godot_cpp/classes/visual_shader_node_vector_base.hpp>

namespace gdrk {
namespace vs {

PortType to_port_type(godot::VisualShaderNodeVectorBase::OpType p_type);
PortType output_swizzle_type(godot::VisualShaderNodeVectorBase::OpType p_type, uint32_t p_port_index);

} // namespace vs
} //namespace gdrk

#define GENERIC_VECTOR_OUTPUT_TYPE()                            \
	OUTPUT_TYPE_F(p_node_wrapper) {                             \
		return gdrk::vs::to_port_type(UNWRAP()->get_op_type()); \
	}

#define GENERIC_VECTOR_INPUT_TYPE()                             \
	INPUT_TYPE_F(p_node_wrapper, p_index_param) {               \
		return gdrk::vs::to_port_type(UNWRAP()->get_op_type()); \
	}
