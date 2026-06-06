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

#include <godot_cpp/classes/visual_shader_node_texture2d_parameter.hpp>

// FYI: https://docs.godotengine.org/en/stable/classes/class_visualshadernodetextureparameter.html

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeTexture2DParameter)
	using TextureType = godot::VisualShaderNodeTextureParameter::TextureType;
	using TextureFilter = godot::VisualShaderNodeTextureParameter::TextureFilter;
	using TextureRepeat = godot::VisualShaderNodeTextureParameter::TextureRepeat;
	using ColorDefault = godot::VisualShaderNodeTextureParameter::ColorDefault;

	static const char *filters[TextureFilter::FILTER_MAX];
	static const char *mip_filters[TextureFilter::FILTER_MAX];
	static int anisotropic_values[TextureFilter::FILTER_MAX];
	static const char *wrap_values[TextureRepeat::REPEAT_MAX];
	static const char *default_colors[ColorDefault::COLOR_DEFAULT_MAX];
	static const char *border_colors[ColorDefault::COLOR_DEFAULT_MAX];

	STATIC_INIT({
		
		filters[TextureFilter::FILTER_DEFAULT]= "default_filter";
		filters[TextureFilter::FILTER_NEAREST] = "\"nearest\"";
		filters[TextureFilter::FILTER_LINEAR] = "\"linear\"";
		filters[TextureFilter::FILTER_NEAREST_MIPMAP]= "default_filter";
		filters[TextureFilter::FILTER_LINEAR_MIPMAP] = "default_filter";
		filters[TextureFilter::FILTER_NEAREST_MIPMAP_ANISOTROPIC] = "default_filter";
		filters[TextureFilter::FILTER_LINEAR_MIPMAP_ANISOTROPIC] = "default_filter";
		
		// nullptr == Does not support mip, default to manual LOD selection 0
		mip_filters[TextureFilter::FILTER_DEFAULT] = nullptr;
		mip_filters[TextureFilter::FILTER_NEAREST] = nullptr;
		mip_filters[TextureFilter::FILTER_LINEAR] = nullptr;
		mip_filters[TextureFilter::FILTER_NEAREST_MIPMAP]= "\"nearest\"";
		mip_filters[TextureFilter::FILTER_LINEAR_MIPMAP] = "\"linear\"";
		mip_filters[TextureFilter::FILTER_NEAREST_MIPMAP_ANISOTROPIC] = "\"nearest\"";
		mip_filters[TextureFilter::FILTER_LINEAR_MIPMAP_ANISOTROPIC] = "\"linear\"";
		
		anisotropic_values[TextureFilter::FILTER_DEFAULT]= 0;
		anisotropic_values[TextureFilter::FILTER_NEAREST] = 0;
		anisotropic_values[TextureFilter::FILTER_LINEAR] = 0;
		anisotropic_values[TextureFilter::FILTER_NEAREST_MIPMAP] = 0;
		anisotropic_values[TextureFilter::FILTER_LINEAR_MIPMAP] = 0;
		anisotropic_values[TextureFilter::FILTER_NEAREST_MIPMAP_ANISOTROPIC] = ENGINE_ANISTROPY_DEFAULT;
		anisotropic_values[TextureFilter::FILTER_LINEAR_MIPMAP_ANISOTROPIC] = ENGINE_ANISTROPY_DEFAULT;
		
		wrap_values[TextureRepeat::REPEAT_DEFAULT] = "default_wrap";
		wrap_values[TextureRepeat::REPEAT_ENABLED] = "\"repeat\"";
		wrap_values[TextureRepeat::REPEAT_DISABLED] = "\"clamp_to_edge\"";
		
		default_colors[ColorDefault::COLOR_DEFAULT_BLACK] = "(0.0f, 0.0f, 0.0f, 1.0f)";
		default_colors[ColorDefault::COLOR_DEFAULT_WHITE] = "(1.0f, 1.0f, 1.0f, 1.0f)";
		default_colors[ColorDefault::COLOR_DEFAULT_TRANSPARENT] = "(0.0f, 0.0f, 0.0f, 0.0f)";
		
		border_colors[ColorDefault::COLOR_DEFAULT_BLACK] = "\"opaque_black\"";
		border_colors[ColorDefault::COLOR_DEFAULT_WHITE] = "\"opaque_white\"";
		border_colors[ColorDefault::COLOR_DEFAULT_TRANSPARENT] = "\"transparent_black\"";
	});

	INLET_COUNT(0)
	OUTPUT_TYPE(PortType::SAMPLER2D)

	DECLARE_UNIFORM(p_node, p_shader_type, p_node_index) {
		TextureType texture_type = NODE()->get_texture_type();
		const godot::String param_name = NODE()->get_parameter_name();
		return UniformDescriptor {
			.name = param_name,
			.type = PortType::SAMPLER2D,
			.default_value = godot::Variant::NIL,
			.srgb_texture = texture_type == TextureType::TYPE_COLOR,
		};
	}

	EXPRESSION(p_context, p_node_wrapper) {
		std::string parameter_name = gdrk::to_std_string(UNWRAP()->get_parameter_name());
		ColorDefault color_default = UNWRAP()->get_color_default();
		const char *default_color = default_colors[color_default];
		const char *border_color = border_colors[color_default];
		
		TextureFilter texture_filter_type = UNWRAP()->get_texture_filter();
		const char *filter = filters[texture_filter_type];
		const char *mip_filter = mip_filters[texture_filter_type];
		bool support_mips = mip_filter != nullptr;
		int anisotropy = anisotropic_values[texture_filter_type];
		
		TextureRepeat repeat_type = UNWRAP()->get_texture_repeat();
		const char *wrap = wrap_values[repeat_type];
		
		std::string auto_lod_function_name = gdrk::get_sampler_function(p_node_wrapper, LODSelection::LOD_SELECTION_AUTO);
		std::string manual_lod_function_name = gdrk::get_sampler_function(p_node_wrapper, LODSelection::LOD_SELECTION_MANUAL);
		
		if (support_mips) {
			p_context.code_parts.push_back(std::format(R"""(let {} = {{ (uv, lod, default_filter, default_wrap) in
				ND_RealityKitTexture2D_vector4({}, {}, {}, {}, {}, {}, {}, {}, 65504f, 0f, {}, uv, false)
			}}; )""", auto_lod_function_name, parameter_name, wrap, wrap, border_color, filter, filter, mip_filter, anisotropy, default_color));
						
						p_context.code_parts.push_back(std::format(R"""(let {} = {{ (uv, lod, default_filter, default_wrap) in
				ND_RealityKitTexture2DLOD_vector4({}, {}, {}, {}, {}, {}, {}, {}, 65504f, 0f, {}, uv, false, lod)
			}}; )""", manual_lod_function_name, parameter_name, wrap, wrap, border_color, filter, filter, mip_filter, anisotropy, default_color));
		} else {
			p_context.code_parts.push_back(std::format(R"""(let {} = {{ (uv, lod, default_filter, default_wrap) in
				ND_RealityKitTexture2DLOD_vector4({}, {}, {}, {}, {}, {}, "none", {}, 65504f, 0f, {}, uv, false, 0.0f)
			}}; )""", auto_lod_function_name, parameter_name, wrap, wrap, border_color, filter, filter, anisotropy, default_color));
			
			p_context.code_parts.push_back(std::format(R"""(let {} = {{ (uv, lod, default_filter, default_wrap) in
				ND_RealityKitTexture2DLOD_vector4({}, {}, {}, {}, {}, {}, "none", {}, 65504f, 0f, {}, uv, false, 0.0f)
			}}; )""", manual_lod_function_name, parameter_name, wrap, wrap, border_color, filter, filter, anisotropy, default_color));
		}
		
		if (support_mips) {
		} else {
	
		}

	}
END(VisualShaderNodeTexture2DParameter)
// clang-format on
