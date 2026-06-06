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

#import "portal_mesh_instance_3d.h"
#import "scene_tree.h"
#import "utility.h"

#include <godot_cpp/classes/engine.hpp>

namespace gdrk {

void RealityPortalMeshInstance3D::_bind_methods() {
	godot::ClassDB::bind_method(godot::D_METHOD("get_flag", "flag"), &RealityPortalMeshInstance3D::get_flag);
	godot::ClassDB::bind_method(godot::D_METHOD("set_flag", "flag", "value"), &RealityPortalMeshInstance3D::set_flag);

	godot::ClassDB::bind_method(godot::D_METHOD("get_target_node"), &RealityPortalMeshInstance3D::get_target_node);
	godot::ClassDB::bind_method(godot::D_METHOD("set_target_node", "target_node"), &RealityPortalMeshInstance3D::set_target_node);
	ADD_PROPERTY(godot::PropertyInfo(godot::Variant::NODE_PATH, "target_node"), "set_target_node", "get_target_node");

	godot::ClassDB::bind_method(godot::D_METHOD("get_clipping_plane_position"), &RealityPortalMeshInstance3D::get_clipping_plane_position);
	godot::ClassDB::bind_method(godot::D_METHOD("set_clipping_plane_position", "clipping_plane_position"), &RealityPortalMeshInstance3D::set_clipping_plane_position);

	godot::ClassDB::bind_method(godot::D_METHOD("get_clipping_plane_normal"), &RealityPortalMeshInstance3D::get_clipping_plane_normal);
	godot::ClassDB::bind_method(godot::D_METHOD("set_clipping_plane_normal", "clipping_plane_normal"), &RealityPortalMeshInstance3D::set_clipping_plane_normal);

	ADD_GROUP("Clipping Plane", "clipping_plane_");
	ADD_PROPERTYI(godot::PropertyInfo(godot::Variant::BOOL, "clipping_plane_enabled", godot::PROPERTY_HINT_GROUP_ENABLE), "set_flag", "get_flag", FLAG_CLIPPING_PLANE_ENABLED);
	ADD_PROPERTY(godot::PropertyInfo(godot::Variant::VECTOR3, "clipping_plane_position"), "set_clipping_plane_position", "get_clipping_plane_position");
	ADD_PROPERTY(godot::PropertyInfo(godot::Variant::VECTOR3, "clipping_plane_normal"), "set_clipping_plane_normal", "get_clipping_plane_normal");

	godot::ClassDB::bind_method(godot::D_METHOD("get_crossing_plane_position"), &RealityPortalMeshInstance3D::get_crossing_plane_position);
	godot::ClassDB::bind_method(godot::D_METHOD("set_crossing_plane_position", "crossing_plane_position"), &RealityPortalMeshInstance3D::set_crossing_plane_position);

	godot::ClassDB::bind_method(godot::D_METHOD("get_crossing_plane_normal"), &RealityPortalMeshInstance3D::get_crossing_plane_normal);
	godot::ClassDB::bind_method(godot::D_METHOD("set_crossing_plane_normal", "crossing_plane_normal"), &RealityPortalMeshInstance3D::set_crossing_plane_normal);

	ADD_GROUP("Crossing Plane", "crossing_plane_");
	ADD_PROPERTYI(godot::PropertyInfo(godot::Variant::BOOL, "crossing_plane_enabled", godot::PROPERTY_HINT_GROUP_ENABLE), "set_flag", "get_flag", FLAG_CROSSING_PLANE_ENABLED);
	ADD_PROPERTY(godot::PropertyInfo(godot::Variant::VECTOR3, "crossing_plane_position"), "set_crossing_plane_position", "get_crossing_plane_position");
	ADD_PROPERTY(godot::PropertyInfo(godot::Variant::VECTOR3, "crossing_plane_normal"), "set_crossing_plane_normal", "get_crossing_plane_normal");
}

} // namespace gdrk
