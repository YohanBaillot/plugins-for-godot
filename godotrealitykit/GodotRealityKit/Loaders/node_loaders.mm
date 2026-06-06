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


#import "node_loaders.h"
#include "Nodes/hierarchical_effect.h"
#include "resource_loaders.h"
#import "signposts.h"

#include <cstdio>
#include <godot_cpp/classes/font.hpp>
#include <godot_cpp/classes/project_settings.hpp>
#include <godot_cpp/classes/skeleton3d.hpp>
#include <godot_cpp/classes/text_server_manager.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/core/engine_ptrcall.hpp>

namespace gdrk {

namespace {

template <typename T>
struct LoaderInit {
	NodeLoaders *owner;
	operator T() const { return T(owner); }
};

template <typename... Ts>
std::tuple<Ts...> make_node_loaders(std::tuple<Ts...> *, NodeLoaders *p_owner) {
	return std::tuple<Ts...>(LoaderInit<Ts>{ p_owner }...);
}

} // namespace

NodeLoaders::NodeLoaders() :
		godot::Object(),
		loaders(make_node_loaders((NodeLoaderSet *)nullptr, this)) {
	get<MeshInstanceLoader>().initialize(&get<CameraLoader>());
}

void NodeLoaders::node_added(godot::Node *p_node) {
	const uint64_t node_id = p_node->get_instance_id();
	node_id_to_topo_priority.insert(node_id, next_topo_priority++);

	if (p_node->has_meta("_gdrk_skip") && p_node->get_meta("_gdrk_skip")) {
		return;
	}

	visit(p_node, [&]<class NodeLoader, class N>(NodeLoader &p_loader, N *p_node) {
		const uint64_t node_id = p_node->get_instance_id();
		if (p_loader.has(node_id)) {
			WARN_COMPAT_MSG("Attempting to add node multiple times");
			return;
		}

		const uint32_t idx = p_loader.add(p_node);

		const uint64_t entity_id = p_loader.get_entity_id(idx);
		if (entity_id) {
			node_id_to_entity_id.insert(node_id, entity_id);
			entity_id_to_node_id.insert(entity_id, node_id);
		}
	});
}

void NodeLoaders::node_removed(godot::Node *p_node) {
	const uint64_t node_id = p_node->get_instance_id();
	node_id_to_topo_priority.erase(node_id);

	if (p_node->has_meta("_gdrk_skip") && p_node->get_meta("_gdrk_skip")) {
		return;
	}

	visit(p_node, [&]<class NodeLoader, class N>(NodeLoader &p_loader, N *p_node) {
		if (!p_loader.has(node_id)) {
			WARN_COMPAT_MSG("Attempting to remove node multiple times");
			return;
		}

		p_loader.remove(p_node);
	});

	if (auto found = node_id_to_entity_id.find(node_id)) {
		entity_id_to_node_id.erase(found->value);
		node_id_to_entity_id.remove(found);
	}
}

void NodeLoaders::update_deps(ResourceLoaderSet &p_resource_loaders) {
	for_each_loader(loaders, [&](auto &p_loader) {
		p_loader.update_deps(p_resource_loaders);
	});
}

void NodeLoaders::update(ResourceLoaderSet &p_resource_loaders) {
	get<CameraLoader>().update(p_resource_loaders);

	for_each_loader(loaders, [&]<typename NodeLoader>(NodeLoader &p_loader) {
		if constexpr (!std::is_same_v<NodeLoader, CameraLoader>) {
			p_loader.update(p_resource_loaders);
		}
	});

	effects.for_each([&]<typename Effect>(HierarchicalEffect<Effect> &effect) {
		effect.flush_propagations();
	});
}

void NodeLoaders::reset_dirty() {
	for_each_loader(loaders, [&](auto &p_loader) {
		p_loader.reset_dirty();
	});
}

} // namespace gdrk
