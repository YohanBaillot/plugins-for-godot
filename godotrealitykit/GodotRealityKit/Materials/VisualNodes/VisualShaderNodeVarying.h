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
#include <godot_cpp/classes/visual_shader.hpp>

namespace gdrk {
namespace vs {

PortType to_port_type(godot::VisualShader::VaryingType p_type);

}
} //namespace gdrk
