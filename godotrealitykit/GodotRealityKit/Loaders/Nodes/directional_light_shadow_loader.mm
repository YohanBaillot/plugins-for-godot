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

//  directional_light_shadow_loader.mm
//  GodotRealityKit
#include "directional_light_shadow_loader.h"
#include "node_loaders.h"

#include <godot_cpp/classes/directional_light3d.hpp>

using namespace gdrk;

uint32_t RealityKitDirectionalLightShadow3DLoader::add(RealityKitDirectionalLightShadow3D *p_node) {
	const uint32_t idx = Base::add(p_node);
	visibility_changed_collector.connect(p_node, idx);
	if (auto *parent = godot::Object::cast_to<godot::DirectionalLight3D>(p_node->get_parent())) {
		owner->get_directional_lights().setFixedShadow(parent, p_node);
	}
	return idx;
}

uint32_t RealityKitDirectionalLightShadow3DLoader::remove(RealityKitDirectionalLightShadow3D *p_node) {
	if (auto *parent = godot::Object::cast_to<godot::DirectionalLight3D>(p_node->get_parent())) {
		owner->get_directional_lights().setFixedShadow(parent, nullptr);
	}
	const uint32_t idx = Base::remove(p_node);
	visibility_changed_collector.disconnect(idx);
	return idx;
}

void RealityKitDirectionalLightShadow3DLoader::_on_visibility_changed(uint32_t p_idx) {
	RealityKitDirectionalLightShadow3D *node = nodes[p_idx];
	if (auto *parent = godot::Object::cast_to<godot::DirectionalLight3D>(node->get_parent())) {
		const bool visible = node->is_visible_in_tree();
		owner->get_directional_lights().setFixedShadow(parent, visible ? node : nullptr);
	}
}
