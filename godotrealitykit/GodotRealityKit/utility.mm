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

#include "utility.h"
#import <Foundation/Foundation.h>

@interface __GDRKBundlePlaceholder : NSObject
@end

@implementation __GDRKBundlePlaceholder {
}
@end

namespace gdrk {

thread_local uint32_t profile_stack_depth = 0;

NSBundle *get_gdrk_bundle() {
	return [NSBundle bundleForClass:[__GDRKBundlePlaceholder class]];
}

} //namespace gdrk
