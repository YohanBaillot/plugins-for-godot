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

#ifndef HOVER_EFFECT
#define HOVER_EFFECT

#include <godot_cpp/classes/node3d.hpp>

namespace gdrk {

class RealityHoverEffect3D : public godot::Node3D {
	GDCLASS(RealityHoverEffect3D, Node3D)

protected:
	static void _bind_methods();

public:
	bool get_color_enabled() const { return color_enabled; }
	void set_color_enabled(bool p_color_enabled) {
		color_enabled = p_color_enabled;
	}

	godot::Color get_color() const { return color; }
	void set_color(const godot::Color &p_color) {
		color = p_color;
	}

	float get_strength() const { return strength; }
	void set_strength(float p_strength) {
		strength = p_strength;
	}

	enum Style {
		STYLE_HIGHLIGHT,
		STYLE_SPOTLIGHT,
	};

	void set_style(Style p_style) { style = p_style; }
	Style get_style() const { return style; }

private:
	bool color_enabled = false;
	godot::Color color;
	float strength = 1.0f;
	Style style = STYLE_HIGHLIGHT;
};

} // namespace gdrk

VARIANT_ENUM_CAST(gdrk::RealityHoverEffect3D::Style);

#endif // HOVER_EFFECT
