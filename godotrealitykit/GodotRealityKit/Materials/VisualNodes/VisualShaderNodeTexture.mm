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

#include "Supported.h"
#include "TextureSampler.h"

#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/classes/visual_shader_node_texture.hpp>

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeTexture)
	using Source = godot::VisualShaderNodeTexture::Source;
	using TextureType = godot::VisualShaderNodeTexture::TextureType;

	// Trying to match Godot uniform naming convention to allow texture updates through material parameters
	static std::string get_uniform_var_name(gdrk::ShaderType p_shader_type, uint32_t p_node_index) {
		return std::format("tex_{}_{}", p_shader_type == ShaderType::ST_VERTEX ? "vtx" : "frg", p_node_index);
	}

	static const char *source_names[Source::SOURCE_MAX];
	static const char *texture_type_names[TextureType::TYPE_MAX];
	static const char *texture_reads[TextureType::TYPE_MAX][LODSelection::LOD_SELECTION_MAX];

	template<TextureType T>
	void texture_type_to_port_type(gdrk::VisualProgramBuilderContext &p_context) {
		p_context.errors.push_back(std::format("VisualShaderNodeTexture::analyze Unsupported texture source {}", source_names[T]));
	}

	template <Source T>
	void analyze(gdrk::VisualProgramBuilderContext &p_context, const gdrk::VisualShaderNodeWrapper &p_node_wrapper) {
		p_context.errors.push_back(std::format("VisualShaderNodeTexture::analyze Unsupported texture source {}", source_names[T]));
	}
	template <Source T>
	void expression(gdrk::VisualProgramBuilderContext &p_context, const gdrk::VisualShaderNodeWrapper &) {
		p_context.errors.push_back(std::format("VisualShaderNodeTexture::expression Unsupported texture source {}", source_names[T]));
	}
	template <Source T>
	OptionalUniformDescriptor declare_uniform(godot::VisualShaderNode *, gdrk::ShaderType, uint32_t) {
		return std::nullopt;
	}

	// Source::SOURCE_TEXTURE
	template<>
	void analyze<Source::SOURCE_TEXTURE>(gdrk::VisualProgramBuilderContext &p_context, const gdrk::VisualShaderNodeWrapper &p_node_wrapper) {

	}

	template<>
	void expression<Source::SOURCE_TEXTURE>(gdrk::VisualProgramBuilderContext &p_context, const gdrk::VisualShaderNodeWrapper &p_node_wrapper) {
		TextureType texture_type = UNWRAP()->get_texture_type();
		bool lod_is_default;
		std::string lod = p_node_wrapper.get_input_expression(p_context, 1, lod_is_default);
		LODSelection selection = lod_is_default ? LODSelection::LOD_SELECTION_AUTO : LODSelection::LOD_SELECTION_MANUAL;
		const char *texture_read = texture_reads[texture_type][selection];

		
		OUTPUT_EXPRESSION(0, std::format("{}({}, {}, {}, {})", texture_read, get_uniform_var_name(p_node_wrapper.shader_type, p_node_wrapper.index), INPUT_EXPRESSION(0), sgl::color::rgba::null_texture(), lod));
	}

	template<>
	OptionalUniformDescriptor declare_uniform<Source::SOURCE_TEXTURE>(godot::VisualShaderNode *p_node, gdrk::ShaderType p_shader_type, uint32_t p_index) {
		std::string param_name = get_uniform_var_name(p_shader_type, p_index);
		godot::StringName godot_param_name = param_name.c_str();
		godot::VisualShaderNodeTexture *node = (godot::VisualShaderNodeTexture *) p_node;
		godot::Ref<godot::Texture2D> texture = node->get_texture();
		TextureType texture_type = node->get_texture_type();
		
		return UniformDescriptor {
			.name = godot_param_name,
			.type = PortType::SAMPLER2D,
			.default_value = texture.ptr(),
			.srgb_texture = texture_type == TextureType::TYPE_COLOR,
		};
	}
	
	// Source::SOURCE_PORT
	template<>
	void analyze<Source::SOURCE_PORT>(gdrk::VisualProgramBuilderContext &p_context, const gdrk::VisualShaderNodeWrapper &p_node_wrapper) {
		const gdrk::VisualShaderNodeWrapper *sampler_node = p_node_wrapper.get_input_node(p_context, 2);
		if (!sampler_node) {
			p_context.warnings.push_back("VisualShaderNodeTexutre::analyze: sampler input not connected to any sampler. Will default to (0.0, 0.0, 0.0, 0.0) output");
			return;
		}
		
		if (sampler_node->node_type != VisualShaderNodeType::VisualShaderNodeTexture2DParameter) {
			p_context.code_parts.push_back("VisualShaderNodeTexutre::analyze: Invalid / Unsupported sampler input connection. Should be of type VisualShaderNodeTexture2DParameter");
			return;
		}
	}

	template<>
	void expression<Source::SOURCE_PORT>(gdrk::VisualProgramBuilderContext &p_context, const gdrk::VisualShaderNodeWrapper &p_node_wrapper) {
		const gdrk::VisualShaderNodeWrapper *sampler_node = p_node_wrapper.get_input_node(p_context, 2);
		if (!sampler_node) {
			OUTPUT_EXPRESSION(0, "(0.0f, 0.0f, 0.0f, 0.0f)");
			return;
		}
		
		bool lod_is_default;
		std::string lod = p_node_wrapper.get_input_expression(p_context, 1, lod_is_default);
		LODSelection selection = lod_is_default ? LODSelection::LOD_SELECTION_AUTO : LODSelection::LOD_SELECTION_MANUAL;
		std::string sampler_function = gdrk::get_sampler_function(*sampler_node, selection);
		
		OUTPUT_EXPRESSION(0, std::format("{}({}, {}, \"linear\", \"repeat\")", sampler_function, INPUT_EXPRESSION(0), lod));
	}

	DEFINE_ENUM_FUNCTION_TABLE(analyze_functions, Source, SOURCE_MAX, analyze)
	DEFINE_ENUM_FUNCTION_TABLE(expression_functions, Source, SOURCE_MAX, expression)
	DEFINE_ENUM_FUNCTION_TABLE(declare_uniform_functions, Source, SOURCE_MAX, declare_uniform)

#define INIT_TEXTURE_TYPE_TABLES(name, with_lod_read, without_lod_read) \
	texture_reads[TextureType::name][LODSelection::LOD_SELECTION_AUTO] = without_lod_read; \
	texture_reads[TextureType::name][LODSelection::LOD_SELECTION_MANUAL] = with_lod_read; \
	texture_type_names[TextureType::name] = #name

#define INIT_SOURCE_NAME_TABLE(name) source_names[Source::name] = #name;

	STATIC_INIT({
		
		INIT_TEXTURE_TYPE_TABLES(TYPE_DATA, "VisualShaderNodeTexture_nearest_with_lod", "VisualShaderNodeTexture_nearest_without_lod");
		INIT_TEXTURE_TYPE_TABLES(TYPE_COLOR, "VisualShaderNodeTexture_linear_mipmap_anisotropic_with_lod", "VisualShaderNodeTexture_linear_mipmap_anisotropic_without_lod");
		INIT_TEXTURE_TYPE_TABLES(TYPE_NORMAL_MAP, "VisualShaderNodeTexture_nearest_with_lod", "VisualShaderNodeTexture_nearest_without_lod");
		
		INIT_SOURCE_NAME_TABLE(SOURCE_TEXTURE);
		INIT_SOURCE_NAME_TABLE(SOURCE_SCREEN);
		INIT_SOURCE_NAME_TABLE(SOURCE_2D_TEXTURE);
		INIT_SOURCE_NAME_TABLE(SOURCE_2D_NORMAL);
		INIT_SOURCE_NAME_TABLE(SOURCE_DEPTH);
		INIT_SOURCE_NAME_TABLE(SOURCE_PORT);
		INIT_SOURCE_NAME_TABLE(SOURCE_3D_NORMAL);
		INIT_SOURCE_NAME_TABLE(SOURCE_ROUGHNESS);
	});

	INLET_COUNT(3)
	OUTPUT_TYPE(VEC4F)
	INPUT_TYPE_F(p_node_wrapper, p_input_index) {
		static PortType inputs_types[3] = {
			PortType::VEC2F,
			PortType::FLOAT,
			PortType::SAMPLER2D,
		};
		return inputs_types[p_input_index];
	}

	DEFAULT_INPUT_VALUE_F(p_node_wrapper, p_input_index) {
		static std::string default_values[3] = {
			sgl::builtin::fragment::uv0(),
			sgl::number::value(0.0f),
			"UNREACHABLE",
		};
		return default_values[p_input_index];
	}

	ANALYZE(p_context, p_node_wrapper) {
		Source source = UNWRAP()->get_source();
		TextureType texture_type = UNWRAP()->get_texture_type();
		if (texture_type >= TextureType::TYPE_MAX) {
			p_context.errors.push_back(std::format("VisualShaderNodeTexture: Texture type value: {}", (uint32_t) texture_type));
			return;
		}
		
		if (source >= Source::SOURCE_MAX) {
			p_context.errors.push_back(std::format("VisualShaderNodeTexture: Invalid source value: {}", (uint32_t) source));
			return;
		}
		
		analyze_functions[source](p_context, p_node_wrapper);
		
		if (p_node_wrapper.get_input_var_name(p_context, 0) == std::nullopt) {
			p_context.uv_used = true;
		}
	}

	DECLARE_UNIFORM(p_node, p_shader_type, p_node_index) {
		Source source = NODE()->get_source();
		return declare_uniform_functions[source](p_node, p_shader_type, p_node_index);
	}

	DECLARATION(p_shader_type, p_context) {
		p_context.code_parts.push_back(std::format(R"""(
			let VisualShaderNodeTexture_nearest_without_lod = {{ (tex, uv, default_color, lod) in
				ND_RealityKitTexture2D_vector4(tex, "repeat", "repeat", "transparent_black", "nearest", "nearest", "none", 0, -, -, default_color, uv, false) 
			}};
			let VisualShaderNodeTexture_nearest_with_lod = {{ (tex, uv, default_color, lod) in
				ND_RealityKitTexture2DLOD_vector4(tex, "repeat", "repeat", "transparent_black", "nearest", "nearest", "nearest", 0, -, -, default_color, uv, false, lod) 
			}};
			let VisualShaderNodeTexture_linear_mipmap_anisotropic_without_lod = {{ (tex, uv, default_color, lod) in
			   ND_RealityKitTexture2D_vector4(tex, "repeat", "repeat", "transparent_black", "linear", "linear", "linear", {}, -, -, default_color, uv, false) 
			}};
			let VisualShaderNodeTexture_linear_mipmap_anisotropic_with_lod = {{ (tex, uv, default_color, lod) in
			   ND_RealityKitTexture2DLOD_vector4(tex, "repeat", "repeat", "transparent_black", "linear", "linear", "linear", {}, -, -, default_color, uv, false, lod) 
			}};
		)""", ENGINE_ANISTROPY_DEFAULT, ENGINE_ANISTROPY_DEFAULT));
	}

	EXPRESSION(p_context, p_node_wrapper) {
		Source source = UNWRAP()->get_source();
		expression_functions[source](p_context, p_node_wrapper);
	}
END(VisualShaderNodeTexture)

