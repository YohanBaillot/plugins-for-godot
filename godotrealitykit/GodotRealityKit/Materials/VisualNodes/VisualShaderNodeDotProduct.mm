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
#include <godot_cpp/classes/visual_shader_node_dot_product.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeDotProduct)
	INLET_COUNT(2)
	INPUT_TYPE(PortType::VEC3F)
	OUTPUT_TYPE(PortType::FLOAT)
	EXPRESSION(p_context, p_node_wrapper) {
		OUTPUT_EXPRESSION(0, std::format("ND_dotproduct_vector3({}, {})", INPUT_EXPRESSION(0), INPUT_EXPRESSION(1)));
	}
END(VisualShaderNodeDotProduct)
