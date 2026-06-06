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

#include "VisualShaderNodeParameter.h"
#include <godot_cpp/classes/visual_shader_node_boolean_parameter.hpp>
#include <godot_cpp/classes/visual_shader_node_color_parameter.hpp>
#include <godot_cpp/classes/visual_shader_node_float_parameter.hpp>
#include <godot_cpp/classes/visual_shader_node_int_parameter.hpp>
#include <godot_cpp/classes/visual_shader_node_u_int_parameter.hpp>
#include <godot_cpp/classes/visual_shader_node_vec2_parameter.hpp>
#include <godot_cpp/classes/visual_shader_node_vec3_parameter.hpp>
#include <godot_cpp/classes/visual_shader_node_vec4_parameter.hpp>

DECLARE_INPUT_PARAMETER_CLASS(VisualShaderNodeBooleanParameter, PortType::BOOL);
DECLARE_INPUT_PARAMETER_CLASS(VisualShaderNodeIntParameter, PortType::INT);

// DECLARE_INPUT_PARAMETER_CLASS(VisualShaderNodeUIntParameter, PortType::UINT)
DECLARE_INPUT_PARAMETER_CLASS(VisualShaderNodeFloatParameter, PortType::FLOAT);
DECLARE_INPUT_PARAMETER_CLASS(VisualShaderNodeVec2Parameter, PortType::VEC2F);
DECLARE_INPUT_PARAMETER_CLASS(VisualShaderNodeVec3Parameter, PortType::VEC3F);
DECLARE_INPUT_PARAMETER_CLASS(VisualShaderNodeVec4Parameter, PortType::VEC4F);
DECLARE_INPUT_PARAMETER_CLASS(VisualShaderNodeColorParameter, PortType::VEC4F);
