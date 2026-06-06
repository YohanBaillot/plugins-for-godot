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

#import <Foundation/Foundation.h>
#import <QuartzCore/CABase.h>
#import <os/log.h>
#import <os/signpost.h>

#include "utility.h"

#define __PROFILE_SCOPE(name, N)                                                           \
	static os_signpost_id_t _sp##N = os_signpost_id_generate(::gdrk::gdrk_log);            \
	::gdrk::profile_stack_depth++;                                                         \
	os_signpost_interval_begin(::gdrk::gdrk_log, _sp##N, name, "%s", __PRETTY_FUNCTION__); \
	::gdrk::detail::defer const _dfr##N =                                                  \
			[scope_start = CACurrentMediaTime(), fn = __PRETTY_FUNCTION__]() {             \
				const uint32_t depth = ::gdrk::profile_stack_depth--;                      \
				CFTimeInterval scope_end = CACurrentMediaTime();                           \
				os_signpost_interval_end(::gdrk::gdrk_log, _sp##N, name, "%s", fn);        \
				if (gdrk::should_print_perf_stats) {                                       \
					CFTimeInterval elapsed = scope_end - scope_start;                      \
					printf("%.5fms", elapsed * 1000.0);                                    \
					for (uint32_t i = 0; i < depth; i++) {                                 \
						printf("\t");                                                      \
					}                                                                      \
					printf("%s %s\n", fn, name);                                           \
				}                                                                          \
			};

#define _PROFILE_SCOPE(name, N) __PROFILE_SCOPE(name, N)
#define PROFILE_SCOPE(name) _PROFILE_SCOPE(name, __COUNTER__)
#define PROFILE_FUNC_SCOPE PROFILE_SCOPE("GodotRealityKit")

namespace gdrk {

namespace detail {
static inline bool should_print_perf_stats() {
	NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
	return [defaults boolForKey:@"gdrk-print-perf-stats"];
}
} // namespace detail

extern thread_local uint32_t profile_stack_depth;
static inline os_log_t gdrk_log = os_log_create("org.godotengine.gdrk", "Performance");

static const bool should_print_perf_stats = detail::should_print_perf_stats();

} //namespace gdrk
