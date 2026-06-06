#===----------------------------------------------------------------------===#
# Copyright © 2026 Apple Inc.
#
# Licensed under the MIT license (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# LICENSE
#
#===----------------------------------------------------------------------===#

extends EditorNode3DGizmoPlugin

func _get_gizmo_name() -> String:
	return "RealityVolumeCamera3D"

func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is RealityVolumeCamera3D

var boxMesh = BoxMesh.new()

func _init():
	add_material("back", preload("res://addons/GodotRealityKit/volume_camera_gizmo/material_back.tres"))
	add_material("front", preload("res://addons/GodotRealityKit/volume_camera_gizmo/material_front.tres"))
	create_material("lines", Color(0.23, 0.692, 1.0, 1.0))
	create_handle_material("handles")

func _redraw(gizmo):
	gizmo.clear()

	var node3d = gizmo.get_node_3d() as RealityVolumeCamera3D

	var radius: float = 0.5 * node3d.size

	var transform = Transform3D.IDENTITY.scaled(2 * radius * Vector3(1, 1, 1))
	gizmo.add_mesh(boxMesh, get_material("back", gizmo), transform)
	gizmo.add_mesh(boxMesh, get_material("front", gizmo), transform)

	var lines = PackedVector3Array()

	# in X
	lines.push_back(Vector3(-1, +1, -1) * radius)
	lines.push_back(Vector3(+1, +1, -1) * radius)
	lines.push_back(Vector3(-1, +1, +1) * radius)
	lines.push_back(Vector3(+1, +1, +1) * radius)
	lines.push_back(Vector3(-1, -1, -1) * radius)
	lines.push_back(Vector3(+1, -1, -1) * radius)
	lines.push_back(Vector3(-1, -1, +1) * radius)
	lines.push_back(Vector3(+1, -1, +1) * radius)

	# in Y
	lines.push_back(Vector3(+1, -1, -1) * radius)
	lines.push_back(Vector3(+1, +1, -1) * radius)
	lines.push_back(Vector3(-1, -1, -1) * radius)
	lines.push_back(Vector3(-1, +1, -1) * radius)
	lines.push_back(Vector3(+1, -1, +1) * radius)
	lines.push_back(Vector3(+1, +1, +1) * radius)
	lines.push_back(Vector3(-1, -1, +1) * radius)
	lines.push_back(Vector3(-1, +1, +1) * radius)

	# in Z
	lines.push_back(Vector3(+1, -1, -1) * radius)
	lines.push_back(Vector3(+1, -1, +1) * radius)
	lines.push_back(Vector3(+1, +1, -1) * radius)
	lines.push_back(Vector3(+1, +1, +1) * radius)
	lines.push_back(Vector3(-1, -1, -1) * radius)
	lines.push_back(Vector3(-1, -1, +1) * radius)
	lines.push_back(Vector3(-1, +1, -1) * radius)
	lines.push_back(Vector3(-1, +1, +1) * radius)

	gizmo.add_lines(lines, get_material("lines", gizmo), false)
