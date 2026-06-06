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

#include "cgimage_util.h"

using namespace gdrk;

CGImageRef gdrk::cgimage_from_godot_image(godot::Ref<godot::Image> p_image) {
	godot::Image::Format format = p_image->get_format();

	assert(format == godot::Image::Format::FORMAT_RGBAF);
	godot::PackedByteArray image_data = p_image->get_data();

	const size_t bytes_per_component = 4;
	const size_t bytes_per_row = 4 * bytes_per_component * p_image->get_width();

	CGContextRef context = CGBitmapContextCreate((void *)image_data.ptr(),
			p_image->get_width(), p_image->get_height(),
			8 * bytes_per_component, bytes_per_row,
			CGColorSpaceCreateWithName(kCGColorSpaceGenericRGBLinear),
			kCGImageAlphaPremultipliedLast | kCGBitmapFloatInfoMask | kCGBitmapByteOrder32Little);

	CGImageRef cgimage = CGBitmapContextCreateImage(context);

	CGContextRelease(context);

	return cgimage;
}
