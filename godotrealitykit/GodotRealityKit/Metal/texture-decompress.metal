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

#include <metal_stdlib>
using namespace metal;

kernel void decompress(texture2d<half, access::sample> sourceTexture [[texture(0)]],
		texture2d<half, access::write> destinationTexture [[texture(1)]],
		uint2 gid [[thread_position_in_grid]]) {
	// Ensure we don't write outside the texture bounds
	if (gid.x >= destinationTexture.get_width() || gid.y >= destinationTexture.get_height()) {
		return;
	}

	half4 color = sourceTexture.read(gid);
	destinationTexture.write(color, gid);
}
