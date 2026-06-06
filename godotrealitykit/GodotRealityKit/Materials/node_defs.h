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

#import "bridge.h"
#include "node_def_embeds.h"

namespace gdrk {
inline swift::Array<swift::String> &get_node_def_files() {
	static swift::Array<swift::String> res = swift::Array<swift::String>::init();
	if (res.getCount() == 0) {
		res.append(swift::String(sg::stdlib_defs));
		res.append(swift::String(sg::apple_defs));
		res.append(swift::String(sg::apple_metal_nodedefs));
		res.append(swift::String(sg::apple_image_nodedefs));
		res.append(swift::String(sg::apple_defs_cameraindex));
		res.append(swift::String(sg::apple_stdlib_extensions));
		res.append(swift::String(sg::apple_light_spill_defs));
		res.append(swift::String(sg::usd_preview_surface));
		res.append(swift::String(sg::apple_bitwise_operations));
		res.append(swift::String(sg::apple_comparison_node_extensions));
	}
	return res;
}

} //namespace gdrk
