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

#ifndef GDRK_H
#define GDRK_H

#import <Metal/Metal.h>

#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#else
#import <UIKit/UIKit.h>
#endif

#import <simd/simd.h>

#ifdef __cplusplus

#include <array>
#include <functional>

namespace gdrk {

class SceneLoader;
class ProgramCache;

} //namespace gdrk

struct GDRKVertexBufferFormat {
	uint32_t vertex_stride;
	uint32_t normal_tangent_stride;
	uint32_t attribute_stride;
	uint32_t vertex_offset;
	uint32_t normal_offset;
	uint32_t tangent_offset;
	uint32_t color_offset;
	uint32_t uv1_offset;
	uint32_t uv2_offset;
	uint32_t skin_stride;
	uint32_t skin_weight_offset;

	friend bool operator==(const GDRKVertexBufferFormat &lhs, const GDRKVertexBufferFormat &rhs) = default;
};

struct GDRKPose {
	simd_float3 position;
	simd_quatf orientation;
};

struct GDRKTransform {
	simd_float3 scale;
	simd_float3 position;
	simd_quatf orientation;

	static GDRKTransform identity;
};

struct GDRKRay {
	simd_float3 origin;
	simd_float3 direction;
};

#if TARGET_OS_OSX
struct GDRKIntersectionInfo {
	simd_float3 position;
	uint64_t entity_id;
};
#endif

typedef NS_ENUM(NSUInteger, PresentationStyle) {
	kVolumetricWindow,
	kVolumetricPortal,
	kImmersive
};

typedef NS_ENUM(NSUInteger, ImmersionStyle) {
	kMixed,
	kFull,
	kProgressive
};

typedef NS_ENUM(NSUInteger, WorldEnvironmentConversion) {
	kAutomatic,
	kEnable,
	kDisable
};

#if TARGET_OS_OSX
using GDRKColor = NSColor;
#else
using GDRKColor = UIColor;
#endif

using GDRKColorRef = GDRKColor *;

class GDRKBridgeDelegate {
public:
	explicit GDRKBridgeDelegate(gdrk::SceneLoader *p_loader) {
		loader = p_loader;
	}

	void printError(const char *p_msg);

	struct ExtensionSettings {
		bool handlesGameControllerEvents;
		PresentationStyle presentationStyle;
		ImmersionStyle immersionStyle;
		WorldEnvironmentConversion worldenvironment;

		bool should_convert_worldenvironment() const;
	};

	ExtensionSettings getExtensionSettings() const;

	void setPHASETransform(GDRKTransform) const;

#if TARGET_OS_OSX
	NSWindow *getDisplayServerWindow() const;
#else
	UIViewController *getDisplayServerViewController() const;
	UIImage *getBootSplashImage() const;
	UIColor *getBootSplashBgColor() const;
#endif

	void *getCameraEntity() const;

	void onWorldScaleChanged(float p_scale) const;

#if TARGET_OS_OSX
	void onWindowResized(simd_float2 p_new_size) const;
#else
	void onWindowResized(simd_float3 p_new_size) const;
#endif

	GDRKTransform getXROrigin() const;

	void onEntityPressUpdate(int64_t p_event_id,
			bool p_ended,
			uint64_t p_entity_id,
			simd_float3 p_position,
			simd_float3 p_hit_position,
			simd_float3 p_hit_normal,
			int64_t p_hit_shape_idx,
			bool p_has_input_device_pose,
			GDRKPose p_input_device_pose,
			bool p_has_selection_ray,
			GDRKRay p_selection_ray,
			bool p_has_chirality,
			uint32_t p_chirality) const;

private:
	mutable gdrk::SceneLoader *loader = nullptr;

	void initialize_phase_manager() const;
};

template <typename Fn>
class GDRKTaskCompletionDelegate;

template <typename R, typename... Ps>
class GDRKTaskCompletionDelegate<R(Ps...)> {
public:
	explicit GDRKTaskCompletionDelegate(std::function<R(Ps...)> p_callback) :
			callback(std::move(p_callback)) {}

	R onCompleted(Ps &&...p_params) const {
		return callback(std::forward<Ps...>(p_params)...);
	}

private:
	std::function<R(Ps...)> callback;
};

using GDRKMaterialLoadDelegate = GDRKTaskCompletionDelegate<void(void *)>;
using GDRKEntityWriteDelegate = GDRKTaskCompletionDelegate<void()>;

#endif // __cplusplus

#endif // GDRK_H
