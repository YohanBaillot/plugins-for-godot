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


#include "light_tunning.h"

#include <godot_cpp/classes/project_settings.hpp>

using namespace gdrk;

LightTunning::LightTunning() :
		use_lux_values(godot::ProjectSettings::get_singleton()->get_setting("rendering/lights_and_shadows/use_physical_light_units")) {
}

LightTunning &LightTunning::get_singleton() {
	static LightTunning _instance;
	return _instance;
}

float LightTunning::get_light_intensity_with_enery_factor(godot::Light3D &light, float energy_factor) {
	if (LightTunning::get_singleton().use_lux_values) {
		return light.get_param(godot::Light3D::Param::PARAM_INTENSITY);
	} else {
		return light.get_param(godot::Light3D::Param::PARAM_ENERGY) * energy_factor;
	}
}
