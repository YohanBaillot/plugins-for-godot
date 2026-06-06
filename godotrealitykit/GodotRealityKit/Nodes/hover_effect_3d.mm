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

#import "hover_effect_3d.h"

#include <godot_cpp/classes/engine.hpp>

namespace gdrk {

void RealityHoverEffect3D::_bind_methods() {
	godot::ClassDB::bind_method(godot::D_METHOD("get_color"), &RealityHoverEffect3D::get_color);
	godot::ClassDB::bind_method(godot::D_METHOD("set_color", "color"), &RealityHoverEffect3D::set_color);

	godot::ClassDB::bind_method(godot::D_METHOD("get_color_enabled"), &RealityHoverEffect3D::get_color_enabled);
	godot::ClassDB::bind_method(godot::D_METHOD("set_color_enabled", "color"), &RealityHoverEffect3D::set_color_enabled);

	ADD_GROUP("Color", "color");
	ADD_PROPERTY(godot::PropertyInfo(godot::Variant::COLOR, "color"), "set_color", "get_color");
	ADD_PROPERTY(godot::PropertyInfo(godot::Variant::BOOL, "color_enabled", godot::PROPERTY_HINT_GROUP_ENABLE), "set_color_enabled", "get_color_enabled");

	godot::ClassDB::bind_method(godot::D_METHOD("get_strength"), &RealityHoverEffect3D::get_strength);
	godot::ClassDB::bind_method(godot::D_METHOD("set_strength", "strength"), &RealityHoverEffect3D::set_strength);
	ADD_PROPERTY(godot::PropertyInfo(godot::Variant::FLOAT, "strength"), "set_strength", "get_strength");

	godot::ClassDB::bind_method(godot::D_METHOD("get_style"), &RealityHoverEffect3D::get_style);
	godot::ClassDB::bind_method(godot::D_METHOD("set_style", "style"), &RealityHoverEffect3D::set_style);
	ADD_PROPERTY(godot::PropertyInfo(godot::Variant::INT, "style", godot::PROPERTY_HINT_ENUM, "Highlight,Spotlight"), "set_style", "get_style");
}

} // namespace gdrk
