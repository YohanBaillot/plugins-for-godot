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

@tool
extends EditorNode3DGizmoPlugin

const HANDLE_Z_NEAR = 0
const HANDLE_Z_FAR = 1
const HANDLE_ORTHO_SCALE = 2

func _get_gizmo_name() -> String:
	return "RealityKitDirectionalLightShadow3D"

func _has_gizmo(node: Node3D) -> bool:
	return node is RealityKitDirectionalLightShadow3D

func _init():
	create_material("lines", Color(0.23, 0.692, 1.0, 1.0))
	create_handle_material("handles")
	var vol_mat := StandardMaterial3D.new()
	vol_mat.albedo_color = Color(0.23, 0.692, 1.0, 0.15)
	vol_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	vol_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	vol_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	add_material("volume", vol_mat)

func _get_handle_count(gizmo: EditorNode3DGizmo) -> int:
	return 3

func _get_handle_name(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool) -> String:
	return ["Z Near", "Z Far", "Orthographic Scale"][handle_id]

func _get_handle_value(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool) -> Variant:
	var node := gizmo.get_node_3d() as RealityKitDirectionalLightShadow3D
	return [node.z_near, node.z_far, node.orthographic_scale][handle_id]

func _set_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, camera: Camera3D, screen_pos: Vector2) -> void:
	var node := gizmo.get_node_3d() as RealityKitDirectionalLightShadow3D
	var gt := node.global_transform
	var ray_o := camera.project_ray_origin(screen_pos)
	var ray_d := camera.project_ray_normal(screen_pos)

	match handle_id:
		HANDLE_Z_NEAR:
			var axis := -gt.basis.z.normalized()
			var d := _project_ray_onto_axis(gt.origin, axis, ray_o, ray_d)
			node.z_near = max(0.001, min(d, node.z_far - 0.001))
		HANDLE_Z_FAR:
			var axis := -gt.basis.z.normalized()
			var d := _project_ray_onto_axis(gt.origin, axis, ray_o, ray_d)
			node.z_far = max(node.z_near + 0.001, d)
		HANDLE_ORTHO_SCALE:
			var axis := gt.basis.x.normalized()
			var zn := -node.z_near
			var zf := -node.z_far
			var mid_z := (zf - zn) * 0.5 + zn
			var axis_origin := gt.origin + mid_z * gt.basis.z
			var d := _project_ray_onto_axis(axis_origin, axis, ray_o, ray_d)
			node.orthographic_scale = max(0.01, d * 2.0)

func _commit_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool,
		restore: Variant, cancel: bool) -> void:
	var node := gizmo.get_node_3d() as RealityKitDirectionalLightShadow3D
	var prop: String = ["z_near", "z_far", "orthographic_scale"][handle_id]
	if cancel:
		node.set(prop, restore)
		return
	var undo := EditorInterface.get_editor_undo_redo()
	undo.create_action("Set Shadow " + prop)
	undo.add_do_property(node, prop, node.get(prop))
	undo.add_undo_property(node, prop, restore)
	undo.commit_action()

func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	var node := gizmo.get_node_3d() as RealityKitDirectionalLightShadow3D
	if not EditorInterface.get_selection().get_selected_nodes().has(node):
		return

	var s := node.orthographic_scale
	var zn := -node.z_near
	var zf := -node.z_far
	var mid_z := (zf - zn) * 0.5 + zn

	# Transparent blue volume
	var depth := node.z_far - node.z_near
	var box_mesh := BoxMesh.new()
	var box_transform := Transform3D(
		Basis.IDENTITY.scaled(Vector3(s, s, depth)),
		Vector3(0.0, 0.0, mid_z)
	)
	gizmo.add_mesh(box_mesh, get_material("volume", gizmo), box_transform)

	# Wireframe edges
	var half_s = 0.5 * s
	var nbl := Vector3(-half_s, -half_s, zn); var nbr := Vector3(half_s, -half_s, zn)
	var ntl := Vector3(-half_s,  half_s, zn); var ntr := Vector3(half_s,  half_s, zn)
	var fbl := Vector3(-half_s, -half_s, zf); var fbr := Vector3(half_s, -half_s, zf)
	var ftl := Vector3(-half_s,  half_s, zf); var ftr := Vector3(half_s,  half_s, zf)

	var lines := PackedVector3Array([
		nbl, nbr,  ntl, ntr,  nbl, ntl,  nbr, ntr,
		fbl, fbr,  ftl, ftr,  fbl, ftl,  fbr, ftr,
		nbl, fbl,  nbr, fbr,  ntl, ftl,  ntr, ftr,
	])
	gizmo.add_lines(lines, get_material("lines", gizmo), false)
	gizmo.add_handles(
		PackedVector3Array([Vector3(0, 0, zn), Vector3(0, 0, zf), Vector3(half_s, 0, mid_z)]),
		get_material("handles", gizmo), []
	)

# Returns the signed distance t such that (origin + t*axis) is the closest
# point on the axis line to the ray (ray_o + u*ray_d).
func _project_ray_onto_axis(origin: Vector3, axis: Vector3,
		ray_o: Vector3, ray_d: Vector3) -> float:
	var ray_to_axis_origin := origin - ray_o
	var axis_ray_cos    := axis.dot(ray_d)
	var ray_dir_sq_len  := ray_d.dot(ray_d)
	var axis_proj       := axis.dot(ray_to_axis_origin)
	var ray_proj        := ray_d.dot(ray_to_axis_origin)
	var parallelism_det := 1.0 - axis_ray_cos * axis_ray_cos / ray_dir_sq_len
	if abs(parallelism_det) < 1e-6:
		return 0.0
	return (axis_ray_cos * ray_proj / ray_dir_sq_len - axis_proj) / parallelism_det
