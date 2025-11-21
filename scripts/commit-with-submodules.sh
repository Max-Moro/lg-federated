#!/bin/bash
# Commit changes in submodules and update federated repo
#
# Usage: ./scripts/commit-with-submodules.sh "commit message"

set -e  # Exit on error

MESSAGE=$1

if [ -z "$MESSAGE" ]; then
    echo "Usage: ./scripts/commit-with-submodules.sh 'commit message'"
    echo "Example: ./scripts/commit-with-submodules.sh 'Add adaptive modes feature'"
    exit 1
fi

echo "Committing changes with message: $MESSAGE"
echo ""

# Track if any changes were committed
CHANGES_COMMITTED=false

# Commit in each submodule (if there are changes)
for module in cli vscode intellij; do
    if [ ! -d "$module" ]; then
        echo "WARNING: $module directory not found, skipping..."
        continue
    fi

    cd "$module" || exit 1

    if [[ -n $(git status -s) ]]; then
        echo "=== Committing in $module ==="
        git add .
        git commit -m "$MESSAGE"
        git push

        CHANGES_COMMITTED=true
        echo "✓ $module: changes committed and pushed"
    else
        echo "- $module: no changes"
    fi

    cd ..
    echo ""
done

# If any submodule was changed, update federated repo
if [ "$CHANGES_COMMITTED" = true ]; then
    echo "=== Updating federated repo ==="

    # Update submodule references
    git submodule update --remote --merge

    # Check if there are changes to commit
    if [[ -n $(git status -s) ]]; then
        git add cli vscode intellij
        git commit -m "Update submodules: $MESSAGE"
        git push

        echo "✓ Federated repo: submodule references updated"
    fi
else
    echo "No changes were committed in any submodule."
fi

echo ""
echo "✓ All changes committed successfully!"
