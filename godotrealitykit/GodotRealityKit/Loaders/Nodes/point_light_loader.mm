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

#include "point_light_loader.h"
#include "bridge.h"
#include "light_tunning.h"
#include "signposts.h"

using namespace gdrk;

void PointLightLoader::update(const ResourceLoaderSet &p_resource_loaders) {
	PROFILE_FUNC_SCOPE;

	Base::update(p_resource_loaders);

	for_each_valid([&](uint32_t idx) {
		godot::OmniLight3D *node = nodes[idx];
		DependencyState &state = dep_states[idx];
		ERR_FAIL_NULL(node);

		float intensity = LightTunning::get_light_intensity(*node);
		float attenuationRadius = node->get_param(godot::Light3D::Param::PARAM_RANGE) * world_scale;
		float attenuationFalloffExponent = node->get_param(godot::Light3D::Param::PARAM_ATTENUATION);
		godot::Color color = node->get_color();

		uint32_t hash = godot::hash_murmur3_one_float(intensity);
		hash = godot::hash_murmur3_one_float(attenuationRadius, hash);
		hash = godot::hash_murmur3_one_float(attenuationFalloffExponent, hash);
		hash = godot::hash_murmur3_one_32(color.to_rgba32(), hash);

		if (state.light_hash != hash) {
			node_entities[idx].entity.setPointLight(gdrk::to_gdrk_color(color), intensity, attenuationRadius, attenuationFalloffExponent);
			state.light_hash = hash;
		}
	});
}
