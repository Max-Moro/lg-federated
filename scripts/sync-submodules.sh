#!/bin/bash
# Sync submodules with their remote branches
#
# Usage: ./scripts/sync-submodules.sh

set -e  # Exit on error

echo "Syncing submodules with upstream..."
echo ""

# Update each submodule to latest commit in its tracked branch
echo "=== Updating submodules ==="
git submodule update --remote --merge

# Show status after update
echo ""
echo "=== Submodule status ==="
git submodule status

# Check if there are changes to commit
echo ""
if [[ -n $(git status -s) ]]; then
    echo "=== Changes detected ==="
    git status

    echo ""
    echo "Submodules have been updated. Review the changes above."
    echo ""
    echo "To commit the updates:"
    echo "  git add cli vscode intellij"
    echo "  git commit -m 'Update submodules to latest'"
    echo "  git push"
else
    echo "✓ All submodules are up to date!"
fi
