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

#include "directional_light_loader.h"
#include "point_light_loader.h"
#include "spot_light_loader.h"

namespace gdrk {

// Singleton used to centralize various light parameterization based on
// godot project settings. should be initialized once
class LightTunning {
	LightTunning();
	LightTunning(const LightTunning &) = delete;
	LightTunning &operator=(const LightTunning &) = delete;

	static LightTunning &get_singleton();
	static float get_light_intensity_with_enery_factor(godot::Light3D &light, float energy_factor);

public:
	static inline float get_light_intensity(godot::DirectionalLight3D &light) {
		return get_light_intensity_with_enery_factor(light, 2500);
	}

	static inline float get_light_intensity(godot::OmniLight3D &light) {
		return get_light_intensity_with_enery_factor(light, 25000);
	}

	static inline float get_light_intensity(godot::SpotLight3D &light) {
		return get_light_intensity_with_enery_factor(light, 2500);
	}

private:
	const bool use_lux_values = false;
};
} //namespace gdrk
