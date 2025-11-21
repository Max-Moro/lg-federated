# Development Guide

This guide covers coordination and workflow for Listing Generator federated repository.

> **Note:** This guide focuses on multi-component workflows. For component-specific development (CLI, VS Code, IntelliJ), see respective README files in submodule directories.

## What is Federated Repository?

This repository coordinates releases and maintains compatibility between three independent components:

```
lg-federated/
├── cli/          → CLI tool (independent releases)
├── vscode/       → VS Code extension (synchronized releases)
├── intellij/     → IntelliJ plugin (synchronized releases)
├── lg-cfg/       → Example configuration
├── docs/         → Coordination documentation
└── scripts/      → Multi-component workflows
```

**When to use federated repo:**
- Planning major releases that span multiple components
- Creating release branches (next-v1.0.x)
- Ensuring API compatibility across ecosystem
- Coordinating synchronized plugin releases

**When NOT needed:**
- Contributing to single component only
- Bug fixes in one component
- Component-specific features

Contributors can work directly in component repositories without cloning federated repo.

---

## Initial Setup

### Clone Repository

```bash
git clone --recurse-submodules git@github.com:Max-Moro/lg-federated.git
cd lg-federated
```

Or if already cloned:
```bash
git submodule update --init --recursive
```

### Setup Components

Run the setup script to initialize submodules:
```bash
./scripts/setup-dev.sh
```

Then follow component-specific instructions:
- **CLI**: See `cli/README.md`
- **VS Code**: See `vscode/README.md`
- **IntelliJ**: See `intellij/README.md`

---

## Helper Scripts

Federated repo provides scripts for coordinating multi-component workflows:

### 1. `switch-branch.sh` - Switch Branches

Switch to existing branch and sync submodules:

```bash
./scripts/switch-branch.sh next-v1.0.x
```

Equivalent to:
```bash
git checkout next-v1.0.x
git submodule update --init --recursive
```

### 2. `create-branch.sh` - Create New Branch

Create branch across all submodules:

```bash
# Feature branch from main
./scripts/create-branch.sh feature/adaptive-modes

# Next release branch
./scripts/create-branch.sh next-v1.0.x

# Hotfix from maintenance branch
./scripts/create-branch.sh hotfix/critical-bug v0.9.x
```

Creates branch in:
1. Each submodule (cli, vscode, intellij)
2. Federated repo
3. Pushes all to origin

### 3. `sync-submodules.sh` - Sync with Upstream

Update submodules to latest commits:

```bash
./scripts/sync-submodules.sh
```

Shows changes ready to commit.

### 4. `commit-with-submodules.sh` - Commit Changes

Commit changes across multiple submodules:

```bash
./scripts/commit-with-submodules.sh "Add adaptive modes feature"
```

Commits and pushes:
1. Changes in each modified submodule
2. Updated submodule references in federated repo

### 5. `setup-dev.sh` - Initial Setup

Initialize submodules and show setup instructions:

```bash
./scripts/setup-dev.sh
```

---

## Branch Strategy

### Branch Types

- `main` - Current stable release
- `next-v1.0.x` - Development branch for next release
- `next-v1.1.x` - Parallel development for future release
- `v0.9.x` - Maintenance branch for hotfixes
- `feature/*` - Feature branches (can be component-specific or cross-component)

### Branch Compatibility

**Important:** All submodules in a federated branch MUST be API-compatible.

Within a branch (e.g., `next-v1.0.x`):
- CLI changes that affect API require updating both IDE plugins
- IDE plugins can have UI-only changes without CLI updates
- Full compatibility is guaranteed within the branch

### Creating Development Branches

**For feature work:**
```bash
./scripts/create-branch.sh feature/my-feature
```

**For release planning (maintainers only):**
```bash
./scripts/create-branch.sh next-v1.0.x
```

### Switching Between Branches

```bash
# Switch to existing branch
./scripts/switch-branch.sh next-v1.0.x

# Switch back to main
./scripts/switch-branch.sh main
```

---

## Working with Submodules

### Making Changes in Single Submodule

```bash
# 1. Make changes in submodule
cd cli
# ... edit files ...
git add .
git commit -m "Add new feature"
git push

# 2. Update federated repo reference
cd ..
git add cli
git commit -m "Update CLI submodule"
git push
```

### Making Changes Across Multiple Submodules

Use helper script:
```bash
# Make changes in cli/, vscode/, intellij/
# Then commit all at once:
./scripts/commit-with-submodules.sh "Add adaptive modes feature"
```

---

## Common Workflows

### Contributing a Feature

**Option A: Single Component** (no federated repo needed)
```bash
# Fork and clone component repo
git clone git@github.com:YOUR_USERNAME/lg-cli.git
cd lg-cli

# Create feature branch
git checkout -b feature/my-feature

# Make changes, test, commit
git add .
git commit -m "Add my feature"

# Push and create PR
git push origin feature/my-feature
```

**Option B: Cross-Component Feature** (use federated repo)
```bash
# Clone federated repo
git clone --recurse-submodules git@github.com:Max-Moro/lg-federated.git
cd lg-federated

# Create feature branch in all submodules
./scripts/create-branch.sh feature/cross-component

# Make changes in cli/, vscode/, intellij/

# Commit all at once
./scripts/commit-with-submodules.sh "Add cross-component feature"

# Create PRs in each affected repo, link them together
```

### Preparing for Release (Maintainers)

```bash
# Create release branch
./scripts/create-branch.sh next-v1.0.x

# Development happens in this branch
# Multiple features are added over time

# When ready to release:
# 1. Update CHANGELOGs in each submodule ([Unreleased] → [1.0.0])
# 2. Follow release process in docs/VERSIONING.md
```

---

## Troubleshooting

### Submodule Detached HEAD

After pulling changes, submodules might be in detached HEAD state:

```bash
cd <submodule>
git checkout main  # or appropriate branch
cd ..
./scripts/sync-submodules.sh
```

### Submodule Out of Sync

If submodule reference doesn't match actual commit:

```bash
git submodule sync
git submodule update --init --recursive
```

### Merge Conflicts in Submodule References

```bash
# Accept theirs
git checkout --theirs <submodule>
git add <submodule>

# Or accept ours
git checkout --ours <submodule>
git add <submodule>

# Then update to actual commit
git submodule update --init --recursive
```

---

## Additional Resources

- [CONTRIBUTING.md](./CONTRIBUTING.md) - Contribution guidelines
- [VERSIONING.md](./VERSIONING.md) - Release process
- [CLI README](../cli/README.md) - CLI-specific development
- [VS Code README](../vscode/README.md) - Extension-specific development
- [IntelliJ README](../intellij/README.md) - Plugin-specific development
