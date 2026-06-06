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

GODOT_EDITOR_BIN="${GODOT_EDITOR_BIN:-"$REPO_DIR/out/shared_workspace/deps/debug/godot/bin/godot.macos.editor.dev.arm64"}"

PROJECT_DIR="$SCRIPT_DIR/empty-project/"

rm -rf "$PROJECT_DIR/addons"
mkdir "$PROJECT_DIR/addons"

ADDON_DIR="${GDRK_ADDON_DIR:-"$REPO_DIR/out/workspace/addons"}"
if [ -d "$ADDON_DIR" ]; then
    for d in "$ADDON_DIR"/*/GodotRealityKit; do
        if [ -d "$d" ]; then
            rsync -av "$d" "$PROJECT_DIR/addons/"
            break
        fi
    done
fi

rm -rf "$PROJECT_DIR/doc_classes"
rsync -av "$REPO_DIR/doc_classes" "$PROJECT_DIR/"

pushd "$PROJECT_DIR" > /dev/null
    "$GODOT_EDITOR_BIN" --doctool . --gdextension-docs
popd > /dev/null

rm -rf "$REPO_DIR/doc_classes"
rsync -av "$PROJECT_DIR/doc_classes" "$REPO_DIR/"

rm -rf "$PROJECT_DIR/doc_classes"
