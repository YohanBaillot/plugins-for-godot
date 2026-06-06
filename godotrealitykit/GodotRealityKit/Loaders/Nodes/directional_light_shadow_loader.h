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

//  directional_light_shadow_loader.h
//  GodotRealityKit
#pragma once

#include "directional_light_loader.h"
#include "directional_light_shadow_3d.h"
#include "node_loader.h"
#include "signal_collector.h"

namespace gdrk {

// Loader for RealityKitDirectionalLightShadow3D nodes.
// Does not create RealityKit entities — it notifies DirectionalLightLoader
// to switch its parent light between automatic and fixed shadow projection.
class RealityKitDirectionalLightShadow3DLoader : public NodeLoaderBase<RealityKitDirectionalLightShadow3DLoader, RealityKitDirectionalLightShadow3D> {
	using Base = NodeLoaderBase<RealityKitDirectionalLightShadow3DLoader, RealityKitDirectionalLightShadow3D>;

public:
	RealityKitDirectionalLightShadow3DLoader(NodeLoaders *p_owner) :
			Base(p_owner) {
		visibility_changed_collector.initialize(this, &RealityKitDirectionalLightShadow3DLoader::_on_visibility_changed);
	}

	void _reserve(uint32_t p_capacity) {
		Base::_reserve(p_capacity);
		visibility_changed_collector.resize(p_capacity);
	}

	uint32_t add(RealityKitDirectionalLightShadow3D *p_node);
	uint32_t remove(RealityKitDirectionalLightShadow3D *p_node);

private:
	void _on_visibility_changed(uint32_t p_idx);

	DECLARE_SIGNAL_COLLECTOR(VisibilityChanged, "visibility_changed", RealityKitDirectionalLightShadow3DLoader, godot::Node3D);
	VisibilityChangedCollector visibility_changed_collector;
};

} // namespace gdrk
