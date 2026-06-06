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

cd "$REPO_DIR/GodotRealityKit"

airFiles=()

mkdir -p "$METAL_LIBRARY_OUTPUT_DIR"

for metalFile in "$REPO_DIR/GodotRealityKit/Metal/"*.metal ; do
    f="$(basename "$metalFile")"
    airFile="$BUILT_PRODUCTS_DIR/${f%.metal}.air"
    airFiles+=("$airFile")

    xcrun -sdk macosx metal \
          -c "$metalFile" \
          -o "$airFile" \
          -std=metal3.0 \
          -target air64-apple-macos15.0
done

xcrun -sdk macosx metallib \
            "${airFiles[@]}" \
            -o "$METAL_LIBRARY_OUTPUT_DIR/default.metallib"
