#!/bin/bash
# Switch to existing branch in federated repo and sync submodules
#
# Usage: ./scripts/switch-branch.sh <branch-name>

set -e  # Exit on error

BRANCH=$1

if [ -z "$BRANCH" ]; then
    echo "Usage: ./scripts/switch-branch.sh <branch-name>"
    echo "Example: ./scripts/switch-branch.sh next-v1.0.x"
    exit 1
fi

echo "Switching to branch: $BRANCH"

# Switch branch in federated repo
git checkout "$BRANCH"

# Sync submodules to match federated repo references
git submodule update --init --recursive

echo ""
echo "✓ Switched to $BRANCH and synced submodules"
