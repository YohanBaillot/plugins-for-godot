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

#include "VisualShaderNodeVarying.h"
#include "utility.h"

using namespace gdrk::vs;
using namespace gdrk;

static PortType type_map[godot::VisualShader::VaryingType::VARYING_TYPE_MAX] = {};
STATIC_INIT({
	type_map[godot::VisualShader::VaryingType::VARYING_TYPE_FLOAT] = PortType::FLOAT;
	type_map[godot::VisualShader::VaryingType::VARYING_TYPE_INT] = PortType::FLOAT;
	type_map[godot::VisualShader::VaryingType::VARYING_TYPE_UINT] = PortType::FLOAT;
	type_map[godot::VisualShader::VaryingType::VARYING_TYPE_VECTOR_2D] = PortType::VEC2F;
	type_map[godot::VisualShader::VaryingType::VARYING_TYPE_VECTOR_3D] = PortType::VEC3F;
	type_map[godot::VisualShader::VaryingType::VARYING_TYPE_VECTOR_4D] = PortType::VEC4F;
	type_map[godot::VisualShader::VaryingType::VARYING_TYPE_BOOLEAN] = PortType::FLOAT;
	type_map[godot::VisualShader::VaryingType::VARYING_TYPE_TRANSFORM] = PortType::UNDEFINED;
});

gdrk::PortType gdrk::vs::to_port_type(godot::VisualShader::VaryingType p_type) {
	return type_map[p_type];
}
