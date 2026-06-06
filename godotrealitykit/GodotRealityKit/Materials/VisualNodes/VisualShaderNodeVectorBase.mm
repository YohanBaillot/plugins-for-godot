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

#include "VisualShaderNodeVectorBase.h"

namespace gdrk {
namespace vs {

static PortType VisualShaderNodeVectorBaseTypeMap[godot::VisualShaderNodeVectorBase::OpType::OP_TYPE_MAX] = {
	PortType::VEC2F,
	PortType::VEC3F,
	PortType::VEC4F
};

PortType to_port_type(godot::VisualShaderNodeVectorBase::OpType p_type) {
	return VisualShaderNodeVectorBaseTypeMap[p_type];
}

PortType output_swizzle_type(godot::VisualShaderNodeVectorBase::OpType p_type, uint32_t p_port_index) {
	return p_port_index == 0 ? VisualShaderNodeVectorBaseTypeMap[p_type] : PortType::FLOAT;
}

} // namespace vs
} //namespace gdrk
