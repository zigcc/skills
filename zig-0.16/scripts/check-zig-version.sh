#!/bin/bash
# Check Zig version via `zig env` and verify it's 0.16.x compatible

set -e

ZIG_CMD="${ZIG_CMD:-zig}"

# Check if zig is available
if ! command -v "$ZIG_CMD" &> /dev/null; then
    echo "ERROR: zig not found. Set ZIG_CMD environment variable or add zig to PATH."
    exit 1
fi

# Extract version from zig env output
VERSION=$("$ZIG_CMD" env | grep '\.version' | head -1 | sed 's/.*"\(.*\)".*/\1/')

if [ -z "$VERSION" ]; then
    echo "ERROR: Could not parse version from 'zig env'."
    exit 1
fi

echo "Zig version: $VERSION"

# Parse major.minor
MAJOR=$(echo "$VERSION" | cut -d. -f1)
MINOR=$(echo "$VERSION" | cut -d. -f2)

if [[ "$MAJOR" -eq 0 && "$MINOR" -ge 16 ]]; then
    echo "OK: Zig 0.16+ detected. This skill applies."
    exit 0
elif [[ "$MAJOR" -ge 1 ]]; then
    echo "OK: Zig 1.x+ detected. This skill should still apply (verify breaking changes)."
    exit 0
else
    echo "WARNING: Zig $MAJOR.$MINOR detected. This skill is for 0.16+."
    echo "Some APIs may differ. Check the migration guide."
    exit 1
fi
