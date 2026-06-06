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

#include "VisualShaderNodeOutput.h"
#include "Supported.h"

#include <godot_cpp/classes/visual_shader_node_output.hpp>
using namespace gdrk;
using namespace gdrk::vs;

// clang-format off
DEFINE_SUPPORTED_NODE(VisualShaderNodeOutput)
	INLET_COUNT_F(p_type) {
		return p_type == ShaderType::ST_FRAGMENT ? (uint32_t)FragmentOutput::FO_COUNT
												 : (uint32_t)VertexOutput::VO_COUNT;
	}

	inline static Span<std::string> init_fragment_defaults() {
		// The documentation for the the VisualShader nodes is very limited in godot, the best
		// way to lookup whant those inputs are doing is by attaching them to constants in the
		// graph editor and read the code it generates, then cross reference it with the spatial shader
		// reference:
		// https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/spatial_shader.html#built-ins
		
		static std::string fragment_defaults[FragmentOutput::FO_COUNT] = {};
		fragment_defaults[FragmentOutput::FO_ALBEDO] = sgl::color::rgb::white();
		fragment_defaults[FragmentOutput::FO_ALPHA] = sgl::number::one<float>();
		fragment_defaults[FragmentOutput::FO_METALLIC] = sgl::number::zero<float>();
		fragment_defaults[FragmentOutput::FO_ROUGHNESS] = sgl::number::value(1.0f);
		fragment_defaults[FragmentOutput::FO_SPECULAR] = sgl::number::value(0.5f);
		fragment_defaults[FragmentOutput::FO_EMISSION] = sgl::color::rgb::black();

		fragment_defaults[FragmentOutput::FO_AO] = sgl::number::one<float>();
		fragment_defaults[FragmentOutput::FO_AO_LIGHT_EFFECT] = sgl::number::zero<float>();

		fragment_defaults[FragmentOutput::FO_NORMAL] = sgl::builtin::normal::tangent();
		fragment_defaults[FragmentOutput::FO_NORMAL_MAP] = sgl::builtin::normal::tangent();
		fragment_defaults[FragmentOutput::FO_NORMAL_MAP_DEPTH] = sgl::number::one<float>();
		
		// Not supported
		fragment_defaults[FO_RIM] = sgl::number::zero<float>();
		fragment_defaults[FO_RIM_TINT] = sgl::number::one<float>();
		
		fragment_defaults[FO_CLEAR_COAT] = sgl::number::zero<float>();
		fragment_defaults[FO_CLEAR_COAT_ROUGHNESS] = sgl::number::value(0.5f);
		
		fragment_defaults[FO_ANISOTROPY] = sgl::number::zero<float>();
		fragment_defaults[FO_ANISOTROPY_FLOW] = sgl::vec2::zeros();
		
		fragment_defaults[FO_SUBSRUFACE_SCATTER] = sgl::number::zero<float>();
		fragment_defaults[FO_BACKLIGHT] = sgl::color::rgb::black();
		
		fragment_defaults[FO_ALPHA_SCISSOR_THRESHOLD] = sgl::number::zero<float>();
		fragment_defaults[FO_ALPHA_HASH_SCALE] = sgl::number::one<float>();
		fragment_defaults[FO_ALPHA_AA_EDGE] = sgl::number::zero<float>();
		fragment_defaults[FO_ALPHA_UV] = sgl::vec2::zeros();
		
		fragment_defaults[FO_DEPTH] = sgl::number::zero<float>();
		fragment_defaults[FO_BENT_NORMAL_MAP] = sgl::number::zero<float>();

		return fragment_defaults;
	}

	inline static Span<std::string> init_vertex_defaults() {
		static std::string vertex_defaults[VertexOutput::VO_COUNT] = {};
		vertex_defaults[VertexOutput::VO_POSITION] = gdrk::sgl::builtin::vertex::position();
		vertex_defaults[VertexOutput::VO_COLOR] = sgl::builtin::vertex::color();
		vertex_defaults[VertexOutput::VO_ALPHA] = sgl::number::one<float>();
		

		vertex_defaults[VertexOutput::VO_UV] = sgl::builtin::vertex::uv0();
		vertex_defaults[VertexOutput::VO_UV2] = sgl::builtin::vertex::uv1();
		
		// Attributes are encoded and need to potentially be decoded.
		vertex_defaults[VertexOutput::VO_TANGENT] = sgl::builtin::vertex::tangent();
		vertex_defaults[VertexOutput::VO_BINORMAL] = sgl::builtin::vertex::bitangent();
		vertex_defaults[VertexOutput::VO_NORMAL] = sgl::builtin::vertex::normal();
		
		return vertex_defaults;
	}

	DEFAULT_INPUT_VALUE_F(p_node_wrapper, p_input_index) {
		static Span<std::string> fragment_defaults = init_fragment_defaults();
		static Span<std::string> vertex_defaults = init_vertex_defaults();

		return p_node_wrapper.is_vertex_shader() ? vertex_defaults[p_input_index] : fragment_defaults[p_input_index];
	}

	inline static PortType *init_fragment_port_types() {
		static PortType port_types[FragmentOutput::FO_COUNT] = {};
		port_types[FragmentOutput::FO_ALBEDO] = PortType::VEC3F;
		port_types[FragmentOutput::FO_ALPHA] = PortType::FLOAT;
		port_types[FragmentOutput::FO_METALLIC] = PortType::FLOAT;
		port_types[FragmentOutput::FO_ROUGHNESS] = PortType::FLOAT;
		port_types[FragmentOutput::FO_SPECULAR] = PortType::FLOAT;
		port_types[FragmentOutput::FO_EMISSION] = PortType::VEC3F;

		port_types[FragmentOutput::FO_AO] = PortType::FLOAT;
		port_types[FragmentOutput::FO_AO_LIGHT_EFFECT] = PortType::FLOAT;

		port_types[FragmentOutput::FO_NORMAL] = PortType::VEC3F;
		port_types[FragmentOutput::FO_NORMAL_MAP] = PortType::VEC3F;
		port_types[FragmentOutput::FO_NORMAL_MAP_DEPTH] = PortType::FLOAT;
		
		// Not supported
		port_types[FO_RIM] = PortType::FLOAT;
		port_types[FO_RIM_TINT] = PortType::FLOAT;
		
		port_types[FO_CLEAR_COAT] = PortType::FLOAT;
		port_types[FO_CLEAR_COAT_ROUGHNESS] = PortType::FLOAT;
		
		port_types[FO_ANISOTROPY] = PortType::FLOAT;
		port_types[FO_ANISOTROPY_FLOW] = PortType::VEC2F;
		
		port_types[FO_SUBSRUFACE_SCATTER] = PortType::FLOAT;
		port_types[FO_BACKLIGHT] = PortType::VEC3F;
		
		port_types[FO_ALPHA_SCISSOR_THRESHOLD] = PortType::FLOAT;
		port_types[FO_ALPHA_HASH_SCALE] = PortType::FLOAT;
		port_types[FO_ALPHA_AA_EDGE] = PortType::FLOAT;
		port_types[FO_ALPHA_UV] = PortType::VEC2F;
		
		port_types[FO_DEPTH] = PortType::FLOAT;
		port_types[FO_BENT_NORMAL_MAP] = PortType::FLOAT;
		return port_types;
	}
	inline static PortType *init_vertex_port_types() {
		static PortType port_types[VertexOutput::VO_COUNT] = {};
		port_types[VertexOutput::VO_POSITION] = PortType::VEC3F;
		port_types[VertexOutput::VO_NORMAL] = PortType::VEC3F;
		port_types[VertexOutput::VO_COLOR] = PortType::VEC3F;
		port_types[VertexOutput::VO_ALPHA] = PortType::FLOAT;
		
		port_types[VertexOutput::VO_TANGENT] = PortType::VEC3F;
		port_types[VertexOutput::VO_BINORMAL] = PortType::VEC3F;
		port_types[VertexOutput::VO_UV] = PortType::VEC2F;
		port_types[VertexOutput::VO_UV2] = PortType::VEC2F;
		return port_types;
	}

	INPUT_TYPE_F(p_node_wrapper, p_input_index) {
		static PortType *fragment_port_types = init_fragment_port_types();
		static PortType *vertex_port_types  = init_vertex_port_types();
		
		return p_node_wrapper.is_vertex_shader() ? vertex_port_types[p_input_index] : fragment_port_types[p_input_index];
	}


	ANALYZE(p_context, p_node_wrapper) {
	   if (p_node_wrapper.get_input_var_name(p_context, VertexOutput::VO_UV) == std::nullopt) {
		   p_context.uv_is_default = true;
	   }
		if (p_node_wrapper.get_input_var_name(p_context, VertexOutput::VO_UV2) == std::nullopt) {
			p_context.uv2_is_default = true;
		}
	}


	EXPRESSION(p_context, p_node_wrapper) {
		bool default_alpha = true;
		if (p_node_wrapper.is_vertex_shader()) {
			// TODO: Add support for Model View Matrix override
			// TODO: Add support for Projection matrix override
			// TODO: Point size override
			// TODO: Add support for ROUGHNESS for vertex lighthing
			std::optional<InputExpression> uv0_var = p_node_wrapper.get_input_var_name(p_context, VertexOutput::VO_UV);
			std::optional<InputExpression> uv1_var = p_node_wrapper.get_input_var_name(p_context, VertexOutput::VO_UV2);
			std::string uv0_expression;
			std::string uv1_expression;
			
			if (p_context.uv_is_default && p_context.uv_used) {
				uv0_expression = p_node_wrapper.get_input_expression(p_context, VertexOutput::VO_UV);
			} else {
				uv0_expression = p_context.varying_allocator.get_vertex_expression_for_uv(0);
			}
			
			if (p_context.uv2_is_default && p_context.uv2_used) {
				uv1_expression = p_node_wrapper.get_input_expression(p_context, VertexOutput::VO_UV2);
			} else {
				uv1_expression = p_context.varying_allocator.get_vertex_expression_for_uv(1);
			}

			p_context.code_parts.push_back(std::format(R"""(
						let VisualShaderNodeOutput_input_position = {};
						let VisualShaderNodeOutput_position_offset = compute_position_offset(VisualShaderNodeOutput_input_position);
						let VisualShaderNodeOutput_color = {};
						let VisualShaderNodeOutput_alpha = {};
						let VisualShaderNodeOutput_normal = {};
						let VisualShaderNodeOutput_tangent = {};
						let VisualShaderNodeOutput_bitangent = {};
						let VisualShaderNodeOutput_uv0 = {};
						let VisualShaderNodeOutput_uv1 = {};
						let VisualShaderNodeOutput_uv2 = {};
						let VisualShaderNodeOutput_uv3 = {};
						let VisualShaderNodeOutput_uv4 = {};
						let VisualShaderNodeOutput_uv5 = {};
						let VisualShaderNodeOutput_uv6 = {};
						let VisualShaderNodeOutput_uv7 = {};
	   
						let VisualShaderNodeOutput_vertex_color = ND_combine4_color4(v3_x(VisualShaderNodeOutput_color), v3_y(VisualShaderNodeOutput_color), v3_z(VisualShaderNodeOutput_color), VisualShaderNodeOutput_alpha);
	   
						let geometry_modifier = ND_realitykit_geometrymodifier_2_0_vertexshader(
							VisualShaderNodeOutput_position_offset,
							VisualShaderNodeOutput_vertex_color,
							VisualShaderNodeOutput_normal, 
							VisualShaderNodeOutput_bitangent,
							VisualShaderNodeOutput_uv0, VisualShaderNodeOutput_uv1,
							VisualShaderNodeOutput_uv2, VisualShaderNodeOutput_uv3,
							VisualShaderNodeOutput_uv4, VisualShaderNodeOutput_uv5,
							VisualShaderNodeOutput_uv6, VisualShaderNodeOutput_uv7
						);
				)""",
					p_node_wrapper.get_input_expression(p_context, VertexOutput::VO_POSITION),
					p_node_wrapper.get_input_expression(p_context, VertexOutput::VO_COLOR),
					p_node_wrapper.get_input_expression(p_context, VertexOutput::VO_ALPHA, default_alpha),
					p_node_wrapper.get_input_expression(p_context, VertexOutput::VO_NORMAL),
					p_node_wrapper.get_input_expression(p_context, VertexOutput::VO_TANGENT),
					p_node_wrapper.get_input_expression(p_context, VertexOutput::VO_BINORMAL),
					uv0_expression,
					uv1_expression,
					p_context.varying_allocator.get_vertex_expression_for_uv(2),
					p_context.varying_allocator.get_vertex_expression_for_uv(3),
					p_context.varying_allocator.get_vertex_expression_for_uv(4),
					p_context.varying_allocator.get_vertex_expression_for_uv(5),
					p_context.varying_allocator.get_vertex_expression_for_uv(6),
					p_context.varying_allocator.get_vertex_expression_for_uv(7)
													   
			));
		} else {
			
			
			p_context.code_parts.push_back(std::format(R"""(
							let VisualShaderNodeOutput_albedo = vec3f_to_rgb({});
							let VisualShaderNodeOutput_emissive_color = vec3f_to_rgb({});
							let VisualShaderNodeOutput_normal = {};
							let VisualShaderNodeOutput_normalMap = {};
							let VisualShaderNodeOutput_normalMapDepth = {};
							let VisualShaderNodeOutput_roughness = {};
							let VisualShaderNodeOutput_metallic = {};
							let VisualShaderNodeOutput_ambientOcclusion = {};
							let VisualShaderNodeOutput_specular = {};
							let VisualShaderNodeOutput_opacity = {};
							let VisualShaderNodeOutput_opacityThreshold = {};
							let VisualShaderNodeOutput_clearcoat = {};
							let VisualShaderNodeOutput_clearcoatRoughness = {};
							let VisualShaderNodeOutput_clearcoatNormal = (0.0f, 0.0f, 1.0f);
							let VisualShaderNodeOutput_hasPremultipliedAlpha = {};
							
							let surface_shader_pbr = ND_realitykit_pbr_surfaceshader(VisualShaderNodeOutput_albedo, 
									VisualShaderNodeOutput_emissive_color, 
									VisualShaderNodeOutput_normal,
									VisualShaderNodeOutput_roughness,
									VisualShaderNodeOutput_metallic, 
									VisualShaderNodeOutput_ambientOcclusion, 
									VisualShaderNodeOutput_specular, 
									VisualShaderNodeOutput_opacity, 
									VisualShaderNodeOutput_opacityThreshold, 
									VisualShaderNodeOutput_clearcoat, 
									VisualShaderNodeOutput_clearcoatRoughness, 
									VisualShaderNodeOutput_clearcoatNormal,
									VisualShaderNodeOutput_hasPremultipliedAlpha
								);
									 
							let surface_shader_unlit_debug = ND_realitykit_unlit_surfaceshader(VisualShaderNodeOutput_albedo, VisualShaderNodeOutput_opacity, -, false, false);
							let surface_shader = surface_shader_pbr;
					)""",
					p_node_wrapper.get_input_expression(p_context, FragmentOutput::FO_ALBEDO),
					p_node_wrapper.get_input_expression(p_context, FragmentOutput::FO_EMISSION),
				    p_node_wrapper.get_input_expression(p_context, FragmentOutput::FO_NORMAL),
					p_node_wrapper.get_input_expression(p_context, FragmentOutput::FO_NORMAL_MAP),
					p_node_wrapper.get_input_expression(p_context, FragmentOutput::FO_NORMAL_MAP_DEPTH),
					p_node_wrapper.get_input_expression(p_context, FragmentOutput::FO_ROUGHNESS),
					p_node_wrapper.get_input_expression(p_context, FragmentOutput::FO_METALLIC),
					p_node_wrapper.get_input_expression(p_context, FragmentOutput::FO_AO),
					p_node_wrapper.get_input_expression(p_context, FragmentOutput::FO_SPECULAR),
					p_node_wrapper.get_input_expression(p_context, FragmentOutput::FO_ALPHA, default_alpha),
					p_node_wrapper.get_input_expression(p_context, FragmentOutput::FO_ALPHA_SCISSOR_THRESHOLD),
					p_node_wrapper.get_input_expression(p_context, FragmentOutput::FO_CLEAR_COAT),
					p_node_wrapper.get_input_expression(p_context, FragmentOutput::FO_CLEAR_COAT_ROUGHNESS),
					false
			));
		}

		p_context.requires_alpha_blending |= !default_alpha;
	}
END(VisualShaderNodeOutput)
