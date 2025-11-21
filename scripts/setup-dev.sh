#!/bin/bash
# Setup development environment for Listing Generator
#
# Usage: ./scripts/setup-dev.sh

set -e  # Exit on error

echo "Setting up Listing Generator development environment..."
echo ""

# Initialize submodules if not already done
if [ ! -d "cli/.git" ] || [ ! -d "vscode/.git" ] || [ ! -d "intellij/.git" ]; then
    echo "=== Initializing submodules ==="
    git submodule update --init --recursive
    echo "✓ Submodules initialized"
    echo ""
fi

# Print setup instructions
echo "========================================="
echo "✓ Repository setup complete!"
echo "========================================="
echo ""
echo "Next steps - setup each component:"
echo ""
echo "1. CLI (Python):"
echo "   See cli/README.md for setup instructions"
echo ""
echo "2. VS Code Extension (TypeScript):"
echo "   See vscode/README.md for setup instructions"
echo ""
echo "3. IntelliJ Plugin (Kotlin):"
echo "   See intellij/README.md for setup instructions"
echo ""
echo "See docs/DEVELOPMENT.md for workflow details."
