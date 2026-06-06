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

#ifndef OBJECT_LOADER_H
#define OBJECT_LOADER_H

#include <array>
#include <bit>

#include "../utility.h"

namespace gdrk {

// Base class for all loader types
// Implements basic pool functionality, including free list management.
// Note that derived classes are responsible for actually storing the pool data associated with each index;
// this class just provides the functionality for allocating new indices and re-using old ones.
// Derived classes must override _reserve() to resize their storage arrays when the pool's capacity grows.
// Also provides a few methods for managing each object's dirty status.
// Note that removed items are marked as dirty, so not all dirty nodes are valid.
template <typename Derived>
class ObjectLoader {
	TESTABLE();

public:
	uint32_t get_capacity() const {
		return capacity;
	}

	void _reserve(uint32_t p_capacity) {
		valid_idxs.resize(p_capacity);
		valid_dirty_idxs.resize(p_capacity);
		dirty_idxs.resize(p_capacity);
	}

	bool is_valid(uint32_t p_idx) const { return valid_idxs.has(p_idx); }

	bool has_dirty() const { return dirty_idxs.count() > 0; }
	bool is_dirty(uint32_t p_idx) const { return dirty_idxs.has(p_idx); }
	void mark_dirty(uint32_t p_idx) { dirty_idxs.insert(p_idx); }
	void mark_clean(uint32_t p_idx) { dirty_idxs.remove(p_idx); }
	void reset_dirty() { dirty_idxs.clear(); }

protected:
	uint32_t alloc_idx() {
		uint32_t res;
		if (free_idxs.is_empty()) {
			res = capacity++;
			static_cast<Derived *>(this)->_reserve(capacity);
		} else {
			res = free_idxs[free_idxs.size() - 1];
			free_idxs.remove_at(free_idxs.size() - 1);
		}

		valid_idxs.insert(res);
		valid_dirty_idxs.insert(res);
		dirty_idxs.insert(res);
		return res;
	}

	void free_idx(uint32_t p_idx) {
		valid_idxs.remove(p_idx);
		valid_dirty_idxs.insert(p_idx);
		dirty_idxs.remove(p_idx);
		free_idxs.push_back(p_idx);
	}

	template <std::invocable<uint32_t> Fn>
	void for_each_added(const Fn &fn) const {
		valid_dirty_idxs.for_each([&](uint32_t idx) {
			const bool is_valid =
					static_cast<const Derived *>(this)->is_valid(idx);
			if (is_valid) {
				fn(idx);
			}
		});
	}

	template <std::invocable<uint32_t> Fn>
	void for_each_removed(const Fn &fn) const {
		valid_dirty_idxs.for_each([&](uint32_t idx) {
			const bool is_valid =
					static_cast<const Derived *>(this)->is_valid(idx);
			if (!is_valid) {
				fn(idx);
			}
		});
	}

	template <std::invocable<uint32_t> Fn>
	void for_each_valid(const Fn &fn) const {
		for (uint32_t idx = 0; idx < capacity; idx++) {
			const bool is_valid =
					static_cast<const Derived *>(this)->is_valid(idx);
			if (is_valid) {
				fn(idx);
			}
		}
	}

	template <std::invocable<uint32_t> Fn>
	void for_each_dirty(const Fn &fn) const {
		dirty_idxs.for_each([&](uint32_t idx) {
			if (static_cast<const Derived *>(this)->is_valid(idx)) {
				fn(idx);
			}
		});
	}

	LocalBitVector dirty_idxs;

private:
	godot::LocalVector<uint32_t> free_idxs;
	LocalBitVector valid_idxs;
	LocalBitVector valid_dirty_idxs;
	uint32_t capacity = 0;
};

} //namespace gdrk

#endif // OBJECT_LOADER_H
