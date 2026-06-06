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

#ifndef IMAGE_BASED_LIGHT
#define IMAGE_BASED_LIGHT

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/ref.hpp>

namespace godot {

class Environment;

} // namespace godot

namespace gdrk {

class RealityImageBasedLight3D : public godot::Node3D {
	GDCLASS(RealityImageBasedLight3D, Node3D)

protected:
	static void _bind_methods();

public:
	void set_environment(const godot::Ref<godot::Environment> &p_env);
	godot::Ref<godot::Environment> get_environment() const;

private:
	godot::Ref<godot::Environment> environment;
};

} // namespace gdrk

#endif // IMAGE_BASED_LIGHT
