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

#include "material_bridge.h"
#include "utility.h"

#include <vector>

namespace gdrk {

class VisualProgramBuilderContext;

class VaryingAllocator {
	TESTABLE();

	struct Slot {
		uint8_t uv_index;
		uint8_t stride;
		bool has_setter = false;
		const char *expression;
		const char *declaration = nullptr;
	};
	static constexpr uint8_t MAX_SLOTS = 28;
	static Slot slot_descriptors[MAX_SLOTS];

	static uint8_t slot_requirement[PortType::PT_COUNT];

public:
	struct VaryingDescriptor {
		PortType type = PortType::UNDEFINED;
		uint8_t slot_ptr = 0;
		uint8_t slot_count = 0;
	};
	VaryingAllocator();

	void reset();
	void release_uv0_slot();
	void release_uv1_slot();

	bool is_supported_type(gdrk::PortType p_type) const;
	const VaryingDescriptor *allocate(const godot::String &p_varying_name, PortType p_type, std::string &p_out_reason);
	const VaryingDescriptor *get_varying(const godot::String &p_varying_name);

	std::string get_vertex_expression_for_uv(uint8_t p_index) const;
	void fill_uv_read_declarations(VisualProgramBuilderContext &p_context);

	// Even though the varying has been allocated, the each slot for that varying needs to have a value, represented
	// by a variable name. That variable name should be used to assign the expression, which is known by the VisualShaderNodeVaryingSetter
	// If a varying is never set, this name is never resolved and we should assign a default (0.0f) value to the slot
	// When this method is called, get_vertex_slot_var_name() can be for that varying
	void assign_varying_slot_names(const VaryingDescriptor &p_varying);
	std::string get_vertex_slot_var_name(const VaryingDescriptor &p_varying, uint8_t p_index) const;

	std::optional<std::string> get_fragment_expression_for_varying(const VaryingAllocator::VaryingDescriptor &p_varying) const;

private:
	// Return the expression to assign the specified UV (0 -> 7)
	std::string get_vertex_slot_expression(uint8_t slot_index) const;

private:
	// UV0 and UV1 are conditinally allocated based on their us in the Vertex Output node
	// Therefore, we will add them to the allocation pool when we identified they aren't used
	// This default value (0) means the UV should not be used
	uint8_t uv0_ptr = 0;
	uint8_t uv1_ptr = 0;
	uint8_t slot_count = 0;
	uint8_t free_slot_pointer = 0;
	Slot slots[MAX_SLOTS];

	godot::HashMap<godot::String, VaryingDescriptor> varyings;
};
} //namespace gdrk
