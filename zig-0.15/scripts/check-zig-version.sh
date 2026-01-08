#!/bin/bash
# Check Zig version and verify it's 0.15.x compatible

set -e

ZIG_CMD="${ZIG_CMD:-zig}"

# Check if zig is available
if ! command -v "$ZIG_CMD" &> /dev/null; then
    echo "ERROR: zig not found. Set ZIG_CMD environment variable or add zig to PATH."
    exit 1
fi

VERSION=$("$ZIG_CMD" version)

echo "Zig version: $VERSION"

# Parse major.minor
MAJOR=$(echo "$VERSION" | cut -d. -f1)
MINOR=$(echo "$VERSION" | cut -d. -f2)

if [[ "$MAJOR" -eq 0 && "$MINOR" -ge 15 ]]; then
    echo "OK: Zig 0.15+ detected. This skill applies."
    exit 0
elif [[ "$MAJOR" -ge 1 ]]; then
    echo "OK: Zig 1.x+ detected. This skill should still apply (verify breaking changes)."
    exit 0
else
    echo "WARNING: Zig $MAJOR.$MINOR detected. This skill is for 0.15+."
    echo "Some APIs may differ. Check the migration guide."
    exit 1
fi
