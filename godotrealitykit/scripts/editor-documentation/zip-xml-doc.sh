#!/bin/bash

#===----------------------------------------------------------------------===#
# Copyright © 2026 Apple Inc.
#
# Licensed under the MIT license (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# LICENSE
#
#===----------------------------------------------------------------------===#

set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(realpath "$SCRIPT_DIR/../../")"

DEPS_DIR="${GODOT_DEPENDENCY_DIR:-"$REPO_DIR/out/shared_workspace/deps/debug"}"

pushd "$REPO_DIR/scripts/editor-documentation" > /dev/null
    scons repo_dir="$REPO_DIR" deps_dir="$DEPS_DIR"
popd > /dev/null
