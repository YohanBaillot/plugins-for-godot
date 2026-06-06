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

// clang-format off
#import "GodotRealityKit.h"
#import "GodotRealityKit-Swift.h"
// clang-format on

#include "program_cache.h"
#include "utility.h"

#undef check
#include <godot_cpp/classes/editor_export_plugin.hpp>

namespace gdrk {

class MaterialEditorExportPlugin;

class MaterialExporter {
public:
	MaterialExporter(MaterialEditorExportPlugin *p_plugin,
			const char *p_export_directory = MATERIAL_EXPORT_DIRECTORY);
	void export_begin();
	void export_visual_shader(const godot::String &p_path);
	void list_exported_files(godot::String p_dir, godot::Vector<godot::String> &p_files_list);
	void export_end();

	inline void set_export_version(int version) { export_version = version; }

private:
	godot::String export_directory;
	swift::Optional<GodotRealityKit::Compiler> compiler;
	MaterialEditorExportPlugin *plugin;
	godot::Dictionary exported_resources;
	int export_version;
};

// Wrapper around exporter to work with godot editor. Separating MaterialExporter from the godot
// class hierarchy makes testing easier.
class MaterialEditorExportPlugin : public godot::EditorExportPlugin {
	GDCLASS(MaterialEditorExportPlugin, godot::EditorExportPlugin);

	static void _bind_methods() {}

public:
	MaterialEditorExportPlugin();
	virtual godot::String _get_name() const override { return "MaterialEditorExportPlugin"; }

	virtual void _export_file(const godot::String &p_path, const godot::String &p_type, const godot::PackedStringArray &p_features) override;
	virtual void _export_end() override;
	virtual void _export_begin(const godot::PackedStringArray &p_features, bool p_is_debug, const godot::String &p_path, uint32_t p_flags) override;

private:
	MaterialExporter exporter;
};
} //namespace gdrk
