# Listing Generator

> Dense code context generation for AI assistants

**Listing Generator** is an ecosystem of tools for generating optimized code contexts for AI assistants like ChatGPT, Claude, Copilot, and Gemini. It transforms your source code into clean, token-efficient Markdown documents that maximize AI understanding while fitting within model context windows.

---

## 🌟 What is Listing Generator?

Modern AI assistants work significantly better when they receive:
- **Structured, filtered code** (no `node_modules/`, build artifacts, or generated files)
- **Normalized formatting** (consistent heading levels, optimized whitespace)
- **Smart compression** (function signatures without bodies, filtered comments)
- **Adaptive contexts** (different views for different tasks: review, development, documentation)

Listing Generator automates this process with a **CLI tool** and **IDE integrations**:

```
Your Project              Listing Generator            AI Assistant
├── src/                  ═══════════════════>         ┌─────────────┐
├── tests/                Clean, optimized             │ ChatGPT     │
├── docs/                 Markdown context             │ Claude      │
├── config/               with statistics              │ Copilot     │
└── node_modules/         and token estimates          │ Gemini      │
    (excluded)                                         └─────────────┘
```

---

## 📦 Components

This is a **federated repository** containing three synchronized components:

| Component | Description | Repository | Distribution |
|-----------|-------------|------------|--------------|
| **CLI** | Core context generation engine | [lg-cli](https://github.com/Max-Moro/lg-cli) | PyPI |
| **VS Code Extension** | Interactive UI for VS Code | [lg-vscode](https://github.com/Max-Moro/lg-vscode) | VS Code Marketplace |
| **IntelliJ Plugin** | Interactive UI for JetBrains IDEs | [lg-intellij](https://github.com/Max-Moro/lg-intellij) | JetBrains Marketplace |

### Architecture

```
lg-federated/
├── cli/          → Core engine (Python)
├── vscode/       → VS Code integration (TypeScript)
├── intellij/     → IntelliJ integration (Kotlin)
├── lg-cfg/       → Example configuration
├── docs/         → Documentation
└── scripts/      → Development utilities
```

---

## 🚀 Quick Start

### For End Users

**Option 1: IDE Plugins (Recommended)**

Install IDE plugin - CLI installs automatically via pipx:
- [VS Code Extension](https://marketplace.visualstudio.com/items?itemName=max-moro.listing-generator) - Zero config, auto-updates
- [IntelliJ Plugin](https://plugins.jetbrains.com/plugin/XXXXX-listing-generator) - Zero config, auto-updates

First run will install `listing-generator` CLI via pipx with version pinning.

**Option 2: Standalone CLI**

```bash
# Install via pipx (recommended)
pipx install listing-generator

# Or via pip
pip install listing-generator

# Verify installation
listing-generator --version
```

**Create starter config:**
```bash
cd your-project/
listing-generator init --preset basic
```

**Generate context:**
```bash
# Generate context for AI
listing-generator render ctx:all --lib tiktoken --encoder cl100k_base --ctx-limit 128000

# Get statistics
listing-generator report ctx:all --lib tiktoken --encoder cl100k_base --ctx-limit 128000
```

### For Developers

**Clone repository:**
```bash
git clone --recurse-submodules git@github.com:Max-Moro/lg-federated.git
cd lg-federated
```

**Setup development environment:**
```bash
./scripts/setup-dev.sh
```

See [DEVELOPMENT.md](./docs/DEVELOPMENT.md) for detailed instructions.

---

## 📚 Documentation

- **[DEVELOPMENT.md](./docs/DEVELOPMENT.md)** - Development environment setup
- **[CONTRIBUTING.md](./docs/CONTRIBUTING.md)** - Contribution guidelines
- **[VERSIONING.md](./docs/VERSIONING.md)** - Release process and versioning