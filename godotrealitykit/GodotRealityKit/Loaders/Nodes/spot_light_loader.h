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

#include "node_loader.h"

#include <godot_cpp/classes/spot_light3d.hpp>

namespace gdrk {

class SpotLightLoader : public NodeLoader<SpotLightLoader, godot::SpotLight3D> {
	NODE_LOADER(SpotLightLoader, NodeLoader, godot::SpotLight3D);

public:
	void update(const ResourceLoaderSet &p_resource_loaders);

	void _reserve(uint32_t p_capacity) {
		Base::_reserve(p_capacity);
		dep_states.resize(p_capacity);
	}

	uint32_t add(godot::SpotLight3D *p_node) {
		const uint32_t idx = Base::add(p_node);
		dep_states[idx] = DependencyState();
		return idx;
	}
	void set_world_scale(float value) { world_scale = value; }

private:
	struct DependencyState {
		uint32_t light_hash = 0;
		bool shadow_enabled = false;
	};

	float world_scale = 1.0;
	godot::LocalVector<DependencyState> dep_states;
};

} //namespace gdrk
