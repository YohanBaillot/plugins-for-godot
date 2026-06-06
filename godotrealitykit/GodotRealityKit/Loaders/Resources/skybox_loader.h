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

#include "resource_loader.h"

#include <godot_cpp/classes/environment.hpp>

namespace gdrk {

/// Turns a `godot::Environment` into a skybox texture.
/// Similar to `gdrk::EnvironmentLoader`.
class SkyboxLoader : public ResourceLoader<SkyboxLoader> {
	GDCLASS(SkyboxLoader, Object);

protected:
	static void _bind_methods() {}

public:
	void _reserve(uint32_t p_capacity) {
		ResourceLoader<SkyboxLoader>::_reserve(p_capacity);
		skyboxes.resize(p_capacity);
	}

	uint32_t find_or_add(godot::RID p_env_rid, godot::Ref<godot::Environment>);

	void remove(uint32_t p_idx) {
		environment_rid_to_idx.remove(skyboxes[p_idx].environment->get_rid());
		godot::Environment *env = skyboxes[p_idx].environment.ptr();
		if (env) {
			disconnect_changed(env, p_idx);
		}

		skyboxes[p_idx] = Skybox();
		free_idx(p_idx);
	}

	GodotRealityKit::Skybox find_resource(godot::RID p_env_rid) const {
		if (!p_env_rid.is_valid()) {
			return GodotRealityKit::Skybox::init();
		}

		ERR_FAIL_COND_V(!environment_rid_to_idx.has(p_env_rid), GodotRealityKit::Skybox::init());
		const uint32_t idx = environment_rid_to_idx.get(p_env_rid);
		return skyboxes[idx].skybox;
	}

	bool update(id<MTLCommandBuffer> p_command_buffer);

private:
	struct Skybox {
		godot::Ref<godot::Environment> environment;
		GodotRealityKit::Skybox skybox = GodotRealityKit::Skybox::init();
	};

	RID_Associated<uint32_t> environment_rid_to_idx;
	godot::LocalVector<Skybox> skyboxes;
};

} // namespace gdrk
