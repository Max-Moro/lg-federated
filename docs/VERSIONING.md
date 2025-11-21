# Versioning and Release Strategy

This document describes the versioning scheme and release process for Listing Generator ecosystem.

## Overview

Listing Generator consists of three components with **different release cycles**:

- **CLI** (`lg-cli`) - Independent release cycle, published to PyPI
- **VS Code Extension** (`lg-vscode`) - Synchronized release cycle, published to VS Code Marketplace
- **IntelliJ Plugin** (`lg-intellij`) - Synchronized release cycle, published to JetBrains Marketplace

## Versioning Scheme

All components follow [Semantic Versioning 2.0.0](https://semver.org/):

```
MAJOR.MINOR.PATCH

MAJOR - Breaking API changes
MINOR - New features (backward compatible)
PATCH - Bug fixes (backward compatible)
```

### Component Independence

**CLI Version:** Independent, drives baseline functionality
```
0.9.0 → 0.10.0 → 1.0.0
```

**IDE Plugin Versions:** Synchronized, pin to CLI MINOR version
```
VS Code:   0.9.0 (requires CLI ^0.9.0, i.e., >=0.9.0 <0.10.0)
IntelliJ:  0.9.0 (requires CLI ^0.9.0, i.e., >=0.9.0 <0.10.0)
```

### Version Compatibility Matrix

| CLI Version | VS Code Version | IntelliJ Version | Compatibility |
|-------------|-----------------|------------------|---------------|
| 0.9.0       | 0.9.0           | 0.9.0           | Initial public release |
| 0.9.1       | 0.9.0           | 0.9.0           | CLI PATCH update auto-installed |
| 0.9.2       | 0.9.0           | 0.9.0           | CLI PATCH update auto-installed |
| 0.10.0      | 0.10.0          | 0.10.0          | New MINOR - plugins updated |
| 0.10.1      | 0.10.0          | 0.10.0          | CLI PATCH update auto-installed |
| 0.10.0      | 0.10.1          | 0.10.1          | Plugin PATCH update (UI only) |

**Rules:**
- IDE plugins **pin to CLI MINOR version** using `^X.Y.0` notation (or `>=X.Y.0,<X.(Y+1).0`)
- CLI PATCH updates (0.9.0→0.9.1) auto-install without plugin updates
- Plugin PATCH updates don't require CLI updates (UI/UX improvements only)
- CLI MINOR/MAJOR updates require synchronized plugin releases with updated pin

## Branch Strategy

### Branch Types

**Stable Branches:**
- `main` - Current stable release (all components at same version)
- `v0.9.x` - Maintenance branch for 0.9.x series (hotfixes only)

**Development Branches:**
- `next-v1.0.x` - Next major/minor release under development
- `next-v1.1.x` - Future release (parallel development)

### Branch Lifecycle

**1. Development Phase (`next-v1.0.x`):**
```bash
# Created when starting work on v1.0.0
./scripts/create-branch.sh next-v1.0.x

# Active development happens here
# Multiple features are added
# API compatibility is maintained within the branch
```

**2. Release Preparation:**
```bash
# Update CHANGELOGs in all submodules
# Move [Unreleased] → [1.0.0] with release date
# Test full integration
# Create release commits
```

**3. Release:**
```bash
# 1. CLI released first
cd cli
git tag v1.0.0
git push origin v1.0.0

# 2. IDE plugins updated to reference CLI v1.0.0
# Update package.json (VS Code) and build.gradle.kts (IntelliJ)

# 3. IDE plugins released simultaneously
cd vscode
git tag v1.0.0
git push origin v1.0.0

cd intellij
git tag v1.0.0
git push origin v1.0.0

# 4. Federated repo tags the combination
cd ..
git tag v1.0.0
git commit -m "Release v1.0.0"
git push origin v1.0.0
```

**4. Post-Release:**
```bash
# Rename next-v1.0.x → v1.0.x (maintenance branch)
git branch -m next-v1.0.x v1.0.x
git push origin v1.0.x
git push origin :next-v1.0.x  # Delete old branch name

# Start work on next version
./scripts/create-branch.sh next-v1.1.x
```

