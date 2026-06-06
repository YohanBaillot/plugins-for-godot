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

#ifndef PORTAL_MESH_INSTANCE_3D
#define PORTAL_MESH_INSTANCE_3D

#include <godot_cpp/classes/mesh_instance3d.hpp>

namespace gdrk {

class RealityPortalMeshInstance3D : public godot::MeshInstance3D {
	GDCLASS(RealityPortalMeshInstance3D, MeshInstance3D);

protected:
	static void _bind_methods();

public:
	enum Flags {
		FLAG_CLIPPING_PLANE_ENABLED,
		FLAG_CROSSING_PLANE_ENABLED,
		FLAG_MAX
	};

	bool get_flag(Flags p_flag) const { return flags[uint32_t(p_flag)]; }
	void set_flag(Flags p_flag, bool p_value) { flags[uint32_t(p_flag)] = p_value; }

	godot::Vector3 get_clipping_plane_position() const { return clipping_plane_position; }
	void set_clipping_plane_position(const godot::Vector3 &p_clipping_plane_position) {
		clipping_plane_position = p_clipping_plane_position;
	}

	godot::Vector3 get_clipping_plane_normal() const { return clipping_plane_normal; }
	void set_clipping_plane_normal(const godot::Vector3 &p_clipping_plane_normal) {
		clipping_plane_normal = p_clipping_plane_normal;
	}

	godot::Vector3 get_crossing_plane_position() const { return crossing_plane_position; }
	void set_crossing_plane_position(const godot::Vector3 &p_crossing_plane_position) {
		crossing_plane_position = p_crossing_plane_position;
	}

	godot::Vector3 get_crossing_plane_normal() const { return crossing_plane_normal; }
	void set_crossing_plane_normal(const godot::Vector3 &p_crossing_plane_normal) {
		crossing_plane_normal = p_crossing_plane_normal;
	}

	godot::NodePath get_target_node() const { return target_node; }
	void set_target_node(const godot::NodePath &p_target_node) {
		target_node = p_target_node;
	}

private:
	godot::Vector3 clipping_plane_position = godot::Vector3(0.0f, 0.0f, 0.0f);
	godot::Vector3 clipping_plane_normal = godot::Vector3(0.0f, 0.0f, 1.0f);
	godot::Vector3 crossing_plane_position = godot::Vector3(0.0f, 0.0f, 0.0f);
	godot::Vector3 crossing_plane_normal = godot::Vector3(0.0f, 0.0f, 1.0f);

	godot::NodePath target_node;
	bool flags[Flags::FLAG_MAX] = {};
};

class RealityPortalCrossing3D : public godot::Node3D {
	GDCLASS(RealityPortalCrossing3D, Node3D);

protected:
	static void _bind_methods() {}
};

} // namespace gdrk

VARIANT_ENUM_CAST(gdrk::RealityPortalMeshInstance3D::Flags)

#endif // PORTAL_MESH_INSTANCE_3D
