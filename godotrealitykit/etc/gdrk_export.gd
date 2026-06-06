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
class_name GDRKEditorExportPlugin
extends EditorExportPlugin

var _pending_visionos_path: String = ""

func _get_name() -> String:
	return "Godot-RealityKit Export Plugin"

func _supports_platform(platform) -> bool:
	var os_name: String = platform.get_os_name()
	if os_name == "visionOS":
		return true
	if os_name == "macOS":
		return ProjectSettings.get_setting("reality_kit/debug_rendering_on_macos", false)
	return false

func _get_features(platform, debug) -> PackedStringArray:
	return PackedStringArray(["gdrk"])

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	_pending_visionos_path = path if features.has("visionos") else ""

func _export_end() -> void:
	if _pending_visionos_path.is_empty():
		return
	var path := _pending_visionos_path
	_pending_visionos_path = ""
	# The public Godot visionOS template hard-codes UIApplicationSupportsMultipleScenes=false
	# in windowed (app_role=0) mode. RealityKit-backed scenes need this true so the plugin
	# can open additional UIWindowScenes at runtime. Patch the generated Info.plist in
	# place — this is a no-op on builds whose template already sets it to true.
	var plist_path := _resolve_visionos_info_plist(path)
	if plist_path.is_empty():
		return
	var f := FileAccess.open(plist_path, FileAccess.READ)
	if f == null:
		push_warning("GDRK export: cannot read %s (err %d)" % [plist_path, FileAccess.get_open_error()])
		return
	var contents := f.get_as_text()
	f.close()
	var false_marker := "<key>UIApplicationSupportsMultipleScenes</key><false/>"
	if not contents.contains(false_marker):
		if not contents.contains("UIApplicationSupportsMultipleScenes"):
			push_warning("GDRK export: UIApplicationSupportsMultipleScenes not found in %s" % plist_path)
		return
	contents = contents.replace(false_marker, "<key>UIApplicationSupportsMultipleScenes</key><true/>")
	var w := FileAccess.open(plist_path, FileAccess.WRITE)
	if w == null:
		push_warning("GDRK export: cannot write %s (err %d)" % [plist_path, FileAccess.get_open_error()])
		return
	w.store_string(contents)
	w.close()
	print("GDRK export: set UIApplicationSupportsMultipleScenes=true in %s" % plist_path)

func _resolve_visionos_info_plist(export_path: String) -> String:
	# visionOS xcodeproj export produces <dir>/<name>.xcodeproj alongside
	# <dir>/<name>/<name>-Info.plist (Godot renames godot_apple_embedded → <name>).
	var project_dir := export_path.get_base_dir()
	var binary_name := export_path.get_file().get_basename()
	var candidate := "%s/%s/%s-Info.plist" % [project_dir, binary_name, binary_name]
	if FileAccess.file_exists(candidate):
		return candidate
	push_warning("GDRK export: Info.plist not found at %s" % candidate)
	return ""
