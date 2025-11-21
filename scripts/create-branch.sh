#!/bin/bash
# Create new branch across all submodules and federated repo
#
# Usage: ./scripts/create-branch.sh <branch-name> [base-branch]
#
# Examples:
#   ./scripts/create-branch.sh feature/adaptive-modes
#   ./scripts/create-branch.sh next-v1.0.x main
#   ./scripts/create-branch.sh hotfix/critical-bug v0.9.x

set -e  # Exit on error

BRANCH=$1
BASE=${2:-main}

if [ -z "$BRANCH" ]; then
    echo "Usage: ./scripts/create-branch.sh <branch-name> [base-branch]"
    echo ""
    echo "Examples:"
    echo "  ./scripts/create-branch.sh feature/adaptive-modes"
    echo "  ./scripts/create-branch.sh next-v1.0.x main"
    echo "  ./scripts/create-branch.sh hotfix/critical-bug v0.9.x"
    exit 1
fi

echo "Creating branch: $BRANCH from base: $BASE"
echo "This will create the branch in all submodules and federated repo."
echo ""

# Confirm with user
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Create branch in each submodule
for module in cli vscode intellij; do
    echo ""
    echo "=== Processing $module ==="

    if [ ! -d "$module" ]; then
        echo "WARNING: $module directory not found, skipping..."
        continue
    fi

    cd "$module" || exit 1

    # Ensure we're on base branch and up to date
    echo "Checking out $BASE branch..."
    git checkout "$BASE"

    echo "Pulling latest changes from $BASE..."
    git pull origin "$BASE"

    # Create new branch from base
    echo "Creating branch $BRANCH from $BASE..."
    git checkout -b "$BRANCH"

    # Push new branch to origin
    echo "Pushing $BRANCH to origin..."
    git push -u origin "$BRANCH"

    cd ..
    echo "✓ $module: branch $BRANCH created and pushed"
done

# Update submodule references to new branches
echo ""
echo "=== Updating submodule references ==="
git submodule update --remote --merge

# Create branch in federated repo
echo ""
echo "=== Creating branch in federated repo ==="
git checkout -b "$BRANCH"

# Stage submodule updates
git add .gitmodules cli vscode intellij

# Commit
git commit -m "Create $BRANCH branch with submodules"

# Push
git push -u origin "$BRANCH"

echo ""
echo "✓ Branch $BRANCH created successfully in all repositories!"
echo ""
echo "Next steps:"
echo "  1. Start development in the new branch"
echo "  2. Maintain API compatibility within this branch"
echo "  3. Update CHANGELOGs as you add features"
