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

#include "spot_light_loader.h"
#include "bridge.h"
#include "light_tunning.h"
#include "signposts.h"
using namespace gdrk;

void SpotLightLoader::update(const ResourceLoaderSet &p_resource_loaders) {
	PROFILE_FUNC_SCOPE;

	Base::update(p_resource_loaders);

	for_each_valid([&](uint32_t idx) {
		godot::SpotLight3D *node = nodes[idx];
		DependencyState &state = dep_states[idx];
		ERR_FAIL_NULL(node);

		if (node->has_shadow() != state.shadow_enabled) {
			state.shadow_enabled = node->has_shadow();
			node_entities[idx].entity.setSpotLightShadow(state.shadow_enabled);
		}

		float intensity = LightTunning::get_light_intensity(*node) * world_scale;
		float outerAngle = node->get_param(godot::Light3D::Param::PARAM_SPOT_ANGLE);
		float spot_attenuation = node->get_param(godot::Light3D::Param::PARAM_SPOT_ATTENUATION);
		float innerAngle = outerAngle - spot_attenuation;
		float attenuationRadius = node->get_param(godot::Light3D::Param::PARAM_RANGE) * world_scale;
		float attenuationFalloffExponent = node->get_param(godot::Light3D::Param::PARAM_ATTENUATION);
		godot::Color color = node->get_color();

		uint32_t hash = godot::hash_murmur3_one_float(intensity);
		hash = godot::hash_murmur3_one_float(innerAngle, hash);
		hash = godot::hash_murmur3_one_float(outerAngle, hash);
		hash = godot::hash_murmur3_one_float(attenuationRadius, hash);
		hash = godot::hash_murmur3_one_float(attenuationFalloffExponent, hash);
		hash = godot::hash_murmur3_one_32(color.to_rgba32(), hash);

		if (state.light_hash != hash) {
			node_entities[idx].entity.setSpotLight(gdrk::to_gdrk_color(color), intensity, 2 * innerAngle, 2 * outerAngle, attenuationRadius, attenuationFalloffExponent);
			state.light_hash = hash;
		}
	});
}
