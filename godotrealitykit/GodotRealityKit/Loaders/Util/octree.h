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

#include <godot_cpp/core/error_macros.hpp>
#include <godot_cpp/core/memory.hpp>
#include <godot_cpp/templates/hash_set.hpp>
#include <godot_cpp/templates/local_vector.hpp>
#include <godot_cpp/variant/aabb.hpp>
#include <godot_cpp/variant/vector3.hpp>

#include <concepts>
#include <functional>

namespace gdrk {

template <typename T>
concept OctreeEntry = requires(T t) {
	{ t.aabb } -> std::convertible_to<godot::AABB>;
};

template <OctreeEntry T>
struct Octree {
	enum TraversalContinuation {
		CONTINUE,
		SKIP_CHILDREN,
		BREAK,
	};

	struct Node {
		using NodePtr = Node *;

		godot::Vector3 bounds_min;
		float size;
		godot::LocalVector<T *> objects;
		NodePtr subnodes[8];
		int object_count;
		bool can_subdivide;

		Node(godot::Vector3 p_bounds_min, float p_size) :
				bounds_min(p_bounds_min),
				size(p_size),
				object_count(0),
				can_subdivide(p_size > 0.001f) {
			subnodes[0] = nullptr;
		}

		~Node() {
			_clear_subnodes();
		}

		bool has_subnodes() const { return subnodes[0] != nullptr; }

		godot::Vector3 get_bounds_max() const {
			return bounds_min + godot::Vector3(size, size, size);
		}

		godot::Vector3 get_center() const {
			return bounds_min + godot::Vector3(size * 0.5f, size * 0.5f, size * 0.5f);
		}

		bool contains(const godot::Vector3 &p_point, float p_radius) const {
			return p_point.x >= (bounds_min.x + p_radius) && p_point.x <= (bounds_min.x + size - p_radius) &&
					p_point.y >= (bounds_min.y + p_radius) && p_point.y <= (bounds_min.y + size - p_radius) &&
					p_point.z >= (bounds_min.z + p_radius) && p_point.z <= (bounds_min.z + size - p_radius);
		}

		bool contains(const T *p_obj) const {
			const godot::Vector3 obj_min = p_obj->aabb.position;
			const godot::Vector3 obj_max = p_obj->aabb.position + p_obj->aabb.size;
			return obj_min.x >= bounds_min.x && obj_max.x <= bounds_min.x + size &&
					obj_min.y >= bounds_min.y && obj_max.y <= bounds_min.y + size &&
					obj_min.z >= bounds_min.z && obj_max.z <= bounds_min.z + size;
		}

		// Returns the index (0–7) of the octant that fully contains p_obj,
		// or -1 if p_obj straddles the center plane on any axis.
		int octant_index(const T *p_obj) const {
			const godot::Vector3 c = get_center();
			const godot::Vector3 obj_min = p_obj->aabb.position;
			const godot::Vector3 obj_max = p_obj->aabb.position + p_obj->aabb.size;

			int index = 0;
			if (obj_min.x >= c.x) {
				index |= 1;
			} else if (obj_max.x > c.x) {
				return -1;
			}
			if (obj_min.y >= c.y) {
				index |= 2;
			} else if (obj_max.y > c.y) {
				return -1;
			}
			if (obj_min.z >= c.z) {
				index |= 4;
			} else if (obj_max.z > c.z) {
				return -1;
			}
			return index;
		}

		void subdivide() {
			const godot::Vector3 c = get_center();
			const float half = size * 0.5f;
			for (int i = 0; i < 8; i++) {
				const godot::Vector3 child_min(
						(i & 1) == 0 ? bounds_min.x : c.x,
						(i & 2) == 0 ? bounds_min.y : c.y,
						(i & 4) == 0 ? bounds_min.z : c.z);
				subnodes[i] = memnew(Node(child_min, half));
			}
		}

		void insert(T *p_obj) {
			object_count++;
			if (!can_subdivide) {
				objects.push_back(p_obj);
				return;
			}
			const int index = octant_index(p_obj);
			if (index == -1) {
				objects.push_back(p_obj);
				return;
			}
			if (!has_subnodes()) {
				subdivide();
			}
			subnodes[index]->insert(p_obj);
		}

		void remove(T *p_obj) {
			object_count--;
			if (object_count == 0) {
				_clear_subnodes();
				objects.clear();
				return;
			}
			const int index = octant_index(p_obj);
			if (index == -1) {
				objects.erase(p_obj);
				return;
			}
			ERR_FAIL_COND(!has_subnodes()); // Unknown object
			subnodes[index]->remove(p_obj);
		}

	private:
		void _clear_subnodes() {
			if (!has_subnodes()) {
				return;
			}
			for (int i = 0; i < 8; i++) {
				if (subnodes[i] != nullptr) {
					godot::memdelete(subnodes[i]);
				}
			}

			subnodes[0] = nullptr;
		}
	}; // struct Node

	// Pair of predicates that define a culling volume. Pass to collect_all().
	// is_object_inbound: returns true if the object's bounding sphere overlaps the volume.
	// is_node_inbound:   returns true if the node's AABB overlaps the volume (used to prune subtrees).
	struct Collector {
		std::function<bool(const T &)> is_object_inbound;
		std::function<bool(const Node &)> is_node_inbound;
	};

	Node *root_node = nullptr;

	Octree() {
		root_node = memnew(Node(godot::Vector3(-0.5f, -0.5f, -0.5f), 1.0f));
	}

	~Octree() {
		if (root_node) {
			godot::memdelete(root_node);
		}
	}

	Octree(const Octree &) = delete;
	Octree &operator=(const Octree &) = delete;

	Octree(Octree &&p_other) :
			root_node(p_other.root_node) {
		p_other.root_node = nullptr;
	}

	// Expands the tree outward until p_point (treated as a zero-radius object) fits inside.
	void grow_to_contain(const godot::Vector3 &p_point) {
		while (!root_node->contains(p_point, 0.0f)) {
			const godot::Vector3 old_min = root_node->bounds_min;

			// Determine which octant the current root should occupy inside the new root.
			// Axes where p_point is below boundsMin shift the old root to the positive side.
			int old_octant = 0;
			if (p_point.x < old_min.x) {
				old_octant |= 1;
			}
			if (p_point.y < old_min.y) {
				old_octant |= 2;
			}
			if (p_point.z < old_min.z) {
				old_octant |= 4;
			}

			Node *old_root = root_node;
			const float new_size = old_root->size * 2.0f;
			const godot::Vector3 new_min(
					(old_octant & 1) != 0 ? old_min.x - old_root->size : old_min.x,
					(old_octant & 2) != 0 ? old_min.y - old_root->size : old_min.y,
					(old_octant & 4) != 0 ? old_min.z - old_root->size : old_min.z);

			root_node = memnew(Node(new_min, new_size));
			if (old_root->object_count != 0) {
				root_node->subdivide();
				// Replace the placeholder child with the old root.
				godot::memdelete(root_node->subnodes[old_octant]);
				root_node->subnodes[old_octant] = old_root;
				root_node->object_count = old_root->object_count;
			} else {
				godot::memdelete(old_root);
			}
		}
	}

	void grow_to_contain(T *p_obj) {
		if (root_node->contains(p_obj)) {
			return;
		}
		const godot::Vector3 obj_min = p_obj->aabb.position;
		const godot::Vector3 obj_max = p_obj->aabb.position + p_obj->aabb.size;
		grow_to_contain(obj_min);
		grow_to_contain(obj_max);
	}

	void insert(T *p_obj) {
		grow_to_contain(p_obj);
		root_node->insert(p_obj);
	}

	void remove(T *p_obj) {
		root_node->remove(p_obj);
		if (root_node->object_count == 0) {
			godot::memdelete(root_node);
			root_node = memnew(Node(godot::Vector3(0, 0, 0), 0.5f));
			return;
		}
		if (root_node->objects.is_empty()) {
			_shrink_root();
		}
	}

	// Iterates nodes depth-first. The callback receives each Node* and returns a
	// TraversalContinuation to control traversal.
	template <typename NodeCallback>
	void traverse(Node *p_start, NodeCallback p_callback) {
		godot::LocalVector<Node *> to_traverse;
		to_traverse.push_back(p_start);
		while (!to_traverse.is_empty()) {
			Node *current = to_traverse[to_traverse.size() - 1];
			to_traverse.resize(to_traverse.size() - 1);
			const TraversalContinuation cont = p_callback(current);
			if (cont == BREAK) {
				break;
			}
			if (cont == SKIP_CHILDREN) {
				continue;
			}
			if (current->has_subnodes()) {
				for (int i = 0; i < 8; i++) {
					to_traverse.push_back(current->subnodes[i]);
				}
			}
		}
	}

	template <typename NodeCallback>
	void traverse_all(NodeCallback p_callback) {
		traverse(root_node, p_callback);
	}

	// Iterates all objects stored in the tree. The callback receives each T* and returns a
	// TraversalContinuation to control traversal.
	template <typename ObjCallback>
	void traverse_all_objects(ObjCallback p_callback) {
		traverse(root_node, [&](Node *node) -> TraversalContinuation {
			for (T *obj : node->objects) {
				const TraversalContinuation cont = p_callback(obj);
				if (cont == BREAK) {
					return BREAK;
				}
			}
			return CONTINUE;
		});
	}

	// Collects into r_result all objects for which the collector's predicates return true.
	void collect_all(const Collector &p_collector, godot::HashSet<T *> &r_result) {
		_collect_with_collector(root_node, p_collector, r_result);
	}

private:
	// Replaces root_node with the unique child that holds all objects, repeating until
	// the root either has objects of its own or cannot shrink further.
	void _shrink_root() {
		bool should_continue = root_node->has_subnodes();
		while (should_continue) {
			should_continue = false;
			for (int i = 0; i < 8; i++) {
				Node *subnode = root_node->subnodes[i];
				if (subnode->object_count == root_node->object_count) {
					root_node->subnodes[i] = nullptr; // detach before deleting parent
					godot::memdelete(root_node);
					root_node = subnode;
					should_continue = root_node->has_subnodes();
					break;
				}
			}
		}
	}

	void _collect_with_collector(Node *p_node, const Collector &p_collector, godot::HashSet<T *> &r_result) {
		if (!p_collector.is_node_inbound(*p_node)) {
			return;
		}

		for (T *obj : p_node->objects) {
			if (p_collector.is_object_inbound(*obj)) {
				r_result.insert(obj);
			}
		}

		if (p_node->has_subnodes()) {
			for (int i = 0; i < 8; i++) {
				if (p_node->subnodes[i]->object_count > 0) {
					_collect_with_collector(p_node->subnodes[i], p_collector, r_result);
				}
			}
		}
	}
};

} // namespace gdrk
