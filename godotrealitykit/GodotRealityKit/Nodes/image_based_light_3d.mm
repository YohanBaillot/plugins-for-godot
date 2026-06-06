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

#import "image_based_light_3d.h"

#include <godot_cpp/classes/environment.hpp>

namespace gdrk {

void RealityImageBasedLight3D::_bind_methods() {
	godot::ClassDB::bind_method(godot::D_METHOD("get_environment"), &RealityImageBasedLight3D::get_environment);
	godot::ClassDB::bind_method(godot::D_METHOD("set_environment", "environment"), &RealityImageBasedLight3D::set_environment);
	ADD_PROPERTY(godot::PropertyInfo(godot::Variant::OBJECT, "environment",
						 godot::PROPERTY_HINT_RESOURCE_TYPE, "Environment"),
			"set_environment", "get_environment");
}

void RealityImageBasedLight3D::set_environment(const godot::Ref<godot::Environment> &p_env) {
	environment = p_env;
}

godot::Ref<godot::Environment> RealityImageBasedLight3D::get_environment() const {
	return environment;
}

} // namespace gdrk
