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

#ifndef cgimage_util_h
#define cgimage_util_h

#include <godot_cpp/classes/image.hpp>

#import <CoreGraphics/CoreGraphics.h>

namespace gdrk {

CGImageRef cgimage_from_godot_image(godot::Ref<godot::Image>);

} // namespace gdrk

#endif /* cgimage_util_h */
