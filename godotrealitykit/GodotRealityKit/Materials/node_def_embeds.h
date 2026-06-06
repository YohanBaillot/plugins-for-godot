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

#ifndef NODE_DEF_EMBEDS_H
#define NODE_DEF_EMBEDS_H

#ifndef __has_embed
#error Compiler must have embed extension enabled
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wc23-extensions"

namespace gdrk {
namespace sg {

const char stdlib_defs[] = {
#embed "NodeDefs/stdlib_defs.mtlx"
	, '\0'
};

const char apple_defs[] = {
#embed "NodeDefs/apple_defs.mtlx"
	, '\0'
};

const char apple_metal_nodedefs[] = {
#embed "NodeDefs/apple_metal_nodedefs.mtlx"
	, '\0'
};

const char apple_image_nodedefs[] = {
#embed "NodeDefs/apple_image_nodedefs.mtlx"
	, '\0'
};

const char apple_defs_cameraindex[] = {
#embed "NodeDefs/apple_defs_cameraindex.mtlx"
	, '\0'
};

const char apple_stdlib_extensions[] = {
#embed "NodeDefs/apple_stdlib_extensions.mtlx"
	, '\0'
};

const char apple_light_spill_defs[] = {
#embed "NodeDefs/apple_light_spill_defs.mtlx"
	, '\0'
};

const char usd_preview_surface[] = {
#embed "NodeDefs/usd_preview_surface.mtlx"
	, '\0'
};

const char apple_bitwise_operations[] = {
#embed "NodeDefs/apple_bitwise_operations.mtlx"
	, '\0'
};

const char apple_comparison_node_extensions[] = {
#embed "NodeDefs/apple_comparison_node_extensions.mtlx"
	, '\0'
};

} // namespace sg
} // namespace gdrk

#pragma clang diagnostic pop

#endif // NODE_DEF_EMBEDS_H
