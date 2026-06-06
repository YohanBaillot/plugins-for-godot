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

#include "program_description.h"

namespace gdrk {

enum BaseMaterialParameter : uint8_t {
	ALBEDO = 0,
	SPECULAR,
	METALLIC,
	ROUGHNESS,
	EMISSION,
	EMISSION_ENERGY,
	NORMAL_SCALE,
	RIM,
	RIM_TINT,
	CLEARCOAT,
	CLEARCOAT_ROUGHNESS,
	ANISOTROPY,
	HEIGHTMAP_SCALE,
	SUBSURFACE_SCATTERING_STRENGTH,
	TRANSMITTANCE_COLOR,
	TRANSMITTANCE_DEPTH,
	TRANSMITTANCE_BOOST,
	BACKLIGHT,
	REFRACTION,
	POINT_SIZE,
	UV1_SCALE,
	UV1_OFFSET,
	UV2_SCALE,
	UV2_OFFSET,
	PARTICLES_ANIM_H_FRAMES,
	PARTICLES_ANIM_V_FRAMES,
	PARTICLES_ANIM_LOOP,
	HEIGHTMAP_MIN_LAYERS,
	HEIGHTMAP_MAX_LAYERS,
	HEIGHTMAP_FLIP,
	UV1_BLEND_SHARPNESS,
	UV2_BLEND_SHARPNESS,
	GROW,
	PROXIMITY_FADE_DISTANCE,
	MSDF_PIXEL_RANGE,
	MSDF_OUTLINE_SIZE,
	DISTANCE_FADE_MIN,
	DISTANCE_FADE_MAX,
	AO_LIGHT_AFFECT,

	METALLIC_TEXTURE_CHANNEL,
	AO_TEXTURE_CHANNEL,
	CLEARCOAT_TEXTURE_CHANNEL,
	RIM_TEXTURE_CHANNEL,
	HEIGHTMAP_TEXTURE_CHANNEL,
	REFRACTION_TEXTURE_CHANNEL,

	TEXTURE_ALBEDO,
	TEXTURE_METALLIC,
	TEXTURE_ROUGHNESS,
	TEXTURE_EMISSION,
	TEXTURE_NORMAL,
	TEXTURE_RIM,
	TEXTURE_CLEARCOAT,
	TEXTURE_FLOWMAP,
	TEXTURE_AMBIENT_OCCLUSION,
	TEXTURE_HEIGHTMAP,
	TEXTURE_SUBSURFACE_SCATTERING,
	TEXTURE_SUBSURFACE_TRANSMITTANCE,
	TEXTURE_BACKLIGHT,
	TEXTURE_REFRACTION,
	TEXTURE_DETAIL_MASK,
	TEXTURE_DETAIL_ALBEDO,
	TEXTURE_DETAIL_NORMAL,
	TEXTURE_BENT_NORMAL,
	TEXTURE_ORM,

	ALPHA_SCISSOR_THRESHOLD,
	ALPHA_HASH_SCALE,

	ALPHA_ANTIALIASING_EDGE,
	ALBEDO_TEXTURE_SIZE,
	Z_CLIP_SCALE,
	FOV_OVERRIDE,

	WORLD_SCALE,

	BM_PARAM_COUNT
};

static_assert(BaseMaterialParameter::TEXTURE_ALBEDO == BaseMaterialParameter::TEXTURE_ALBEDO + godot::BaseMaterial3D::TextureParam::TEXTURE_ALBEDO);
static_assert(BaseMaterialParameter::TEXTURE_METALLIC == BaseMaterialParameter::TEXTURE_ALBEDO + godot::BaseMaterial3D::TextureParam::TEXTURE_METALLIC);
static_assert(BaseMaterialParameter::TEXTURE_ROUGHNESS == BaseMaterialParameter::TEXTURE_ALBEDO + godot::BaseMaterial3D::TextureParam::TEXTURE_ROUGHNESS);
static_assert(BaseMaterialParameter::TEXTURE_EMISSION == BaseMaterialParameter::TEXTURE_ALBEDO + godot::BaseMaterial3D::TextureParam::TEXTURE_EMISSION);
static_assert(BaseMaterialParameter::TEXTURE_NORMAL == BaseMaterialParameter::TEXTURE_ALBEDO + godot::BaseMaterial3D::TextureParam::TEXTURE_NORMAL);
static_assert(BaseMaterialParameter::TEXTURE_RIM == BaseMaterialParameter::TEXTURE_ALBEDO + godot::BaseMaterial3D::TextureParam::TEXTURE_RIM);
static_assert(BaseMaterialParameter::TEXTURE_CLEARCOAT == BaseMaterialParameter::TEXTURE_ALBEDO + godot::BaseMaterial3D::TextureParam::TEXTURE_CLEARCOAT);
static_assert(BaseMaterialParameter::TEXTURE_FLOWMAP == BaseMaterialParameter::TEXTURE_ALBEDO + godot::BaseMaterial3D::TextureParam::TEXTURE_FLOWMAP);
static_assert(BaseMaterialParameter::TEXTURE_AMBIENT_OCCLUSION == BaseMaterialParameter::TEXTURE_ALBEDO + godot::BaseMaterial3D::TextureParam::TEXTURE_AMBIENT_OCCLUSION);
static_assert(BaseMaterialParameter::TEXTURE_HEIGHTMAP == BaseMaterialParameter::TEXTURE_ALBEDO + godot::BaseMaterial3D::TextureParam::TEXTURE_HEIGHTMAP);
static_assert(BaseMaterialParameter::TEXTURE_SUBSURFACE_SCATTERING == BaseMaterialParameter::TEXTURE_ALBEDO + godot::BaseMaterial3D::TextureParam::TEXTURE_SUBSURFACE_SCATTERING);
static_assert(BaseMaterialParameter::TEXTURE_SUBSURFACE_TRANSMITTANCE == BaseMaterialParameter::TEXTURE_ALBEDO + godot::BaseMaterial3D::TextureParam::TEXTURE_SUBSURFACE_TRANSMITTANCE);
static_assert(BaseMaterialParameter::TEXTURE_BACKLIGHT == BaseMaterialParameter::TEXTURE_ALBEDO + godot::BaseMaterial3D::TextureParam::TEXTURE_BACKLIGHT);
static_assert(BaseMaterialParameter::TEXTURE_REFRACTION == BaseMaterialParameter::TEXTURE_ALBEDO + godot::BaseMaterial3D::TextureParam::TEXTURE_REFRACTION);
static_assert(BaseMaterialParameter::TEXTURE_DETAIL_MASK == BaseMaterialParameter::TEXTURE_ALBEDO + godot::BaseMaterial3D::TextureParam::TEXTURE_DETAIL_MASK);
static_assert(BaseMaterialParameter::TEXTURE_DETAIL_ALBEDO == BaseMaterialParameter::TEXTURE_ALBEDO + godot::BaseMaterial3D::TextureParam::TEXTURE_DETAIL_ALBEDO);
static_assert(BaseMaterialParameter::TEXTURE_DETAIL_NORMAL == BaseMaterialParameter::TEXTURE_ALBEDO + godot::BaseMaterial3D::TextureParam::TEXTURE_DETAIL_NORMAL);

class BaseMaterialBuilder {
public:
	static const godot::StringName *get_godot_parameter_name_table();
	static const char *get_parameter_name(BaseMaterialParameter p_param);
	static const godot::StringName &get_godot_parameter_name(BaseMaterialParameter p_param);
	static const godot::StringName &get_texture_parameter_name(uint32_t p_texture_idx);

	static void finalize(const BaseMaterial3DDescription &p_description, GodotRealityKit::SGLProgram &p_program);

	BaseMaterialBuilder(swift::Optional<GodotRealityKit::Compiler> p_compiler,
			const BaseMaterial3DDescription &p_program_description);

	bool build(swift::Array<GodotRealityKit::ProgramPart> &program_parts);

private:
	swift::Optional<GodotRealityKit::Compiler> compiler;
	const BaseMaterial3DDescription &program_description;
};

} //namespace gdrk
