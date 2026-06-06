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

#include "bridge.h"
#include <godot_cpp/variant/builtin_types.hpp>
#include <string>

namespace gdrk {

inline GodotRealityKit::Vector3 to_vector3(godot::Vector3 v) {
	return GodotRealityKit::Vector3::init(v.x, v.y, v.z);
}

inline GodotRealityKit::Vector4 to_vector4(godot::Color v) {
	return GodotRealityKit::Vector4::init(v.r, v.g, v.b, v.a);
}

inline GodotRealityKit::Vector4 to_vector4(godot::Vector4 v) {
	return GodotRealityKit::Vector4::init(v.x, v.y, v.z, v.w);
}

inline GodotRealityKit::Vector4 to_vector4(godot::Quaternion v) {
	return GodotRealityKit::Vector4::init(v.x, v.y, v.z, v.w);
}

inline godot::Vector2 from_simd2(simd_float2 v) {
	return godot::Vector2(v.x, v.y);
}

inline godot::Vector3 from_simd3(simd_float3 v) {
	return godot::Vector3(v.x, v.y, v.z);
}

inline godot::Quaternion from_quatf(simd_quatf v) {
	return godot::Quaternion(v.vector.x, v.vector.y, v.vector.z, v.vector.w);
}

inline simd_float2 to_simd2(godot::Vector2 v) {
	return simd_make_float2(v.x, v.y);
}

inline simd_float3 to_simd3(godot::Vector3 v) {
	return simd_make_float3(v.x, v.y, v.z);
}

inline simd_float4 to_simd4(godot::Vector4 v) {
	return simd_make_float4(v.x, v.y, v.z, v.w);
}

inline simd_quatf to_quatf(godot::Quaternion v) {
	return simd_quaternion(v.x, v.y, v.z, v.w);
}

inline simd_float4x3 to_simd4x3(godot::Transform3D t) {
	return simd_matrix(to_simd3(t.basis[0]), to_simd3(t.basis[1]),
			to_simd3(t.basis[2]), to_simd3(t.origin));
}

inline simd_float3x3 to_simd3x3(godot::Basis b) {
	return simd_matrix(to_simd3(b[0]), to_simd3(b[1]), to_simd3(b[2]));
}

inline GDRKTransform to_transform(godot::Transform3D v) {
	return GDRKTransform{
		.scale = to_simd3(v.get_basis().get_scale()),
		.position = to_simd3(v.get_origin()),
		.orientation = to_quatf(v.get_basis().get_rotation_quaternion())
	};
}

#if TARGET_OS_OSX
inline GDRKColor *to_gdrk_color(const godot::Color &v) {
	const CGFloat r = CGFloat(v.get_r8()) / CGFloat(255.0);
	const CGFloat g = CGFloat(v.get_g8()) / CGFloat(255.0);
	const CGFloat b = CGFloat(v.get_b8()) / CGFloat(255.0);
	const CGFloat a = CGFloat(v.get_a8()) / CGFloat(255.0);

	return [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a];
}
#else
inline GDRKColor *to_gdrk_color(const godot::Color &v) {
	const CGFloat r = CGFloat(v.get_r8()) / CGFloat(255.0);
	const CGFloat g = CGFloat(v.get_g8()) / CGFloat(255.0);
	const CGFloat b = CGFloat(v.get_b8()) / CGFloat(255.0);
	const CGFloat a = CGFloat(v.get_a8()) / CGFloat(255.0);

	return [UIColor colorWithRed:r green:g blue:b alpha:a];
}
#endif

inline std::string to_std_string(const godot::String &string) {
	const auto utf8 = string.to_utf8_buffer();
	return std::string((const char *)utf8.ptr(), utf8.size());
}

inline std::string to_std_string(const godot::Vector3 &v) {
	return to_std_string(godot::String("(") + godot::String::num(v.x, 2) + ", " + godot::String::num(v.y, 2) + ", " + godot::String::num(v.z, 2) + ")");
}

inline swift::String to_swift_string(const godot::StringName &string) {
	const auto utf8 = string.to_utf8_buffer();
	return swift::String(std::string((const char *)utf8.ptr(), utf8.size()));
}

inline swift::String to_swift_string(const godot::String &string) {
	const godot::PackedByteArray bytes = string.to_utf8_buffer();
	return swift::String(std::string((const char *)bytes.ptr(), bytes.size()));
}

inline GodotRealityKit::Matrix44 to_matrix44(godot::Transform3D t) {
	GodotRealityKit::Vector4 c0 = GodotRealityKit::Vector4::init(t.basis[0].x, t.basis[1].x, t.basis[2].x, 0.0);
	GodotRealityKit::Vector4 c1 = GodotRealityKit::Vector4::init(t.basis[0].y, t.basis[1].y, t.basis[2].y, 0.0);
	GodotRealityKit::Vector4 c2 = GodotRealityKit::Vector4::init(t.basis[0].z, t.basis[1].z, t.basis[2].z, 0.0);
	GodotRealityKit::Vector4 c3 = GodotRealityKit::Vector4::init(t.origin.x, t.origin.y, t.origin.z, 1.0);
	return GodotRealityKit::Matrix44::init(c0, c1, c2, c3);
}

} //namespace gdrk
