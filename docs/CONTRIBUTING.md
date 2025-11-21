# Contributing to Listing Generator

Thank you for your interest in contributing to Listing Generator!

## Code of Conduct

Be respectful, inclusive, and professional in all interactions.

## Ways to Contribute

- **Bug reports** - Help us identify and fix issues
- **Feature requests** - Suggest new capabilities
- **Code contributions** - Implement features or fix bugs
- **Documentation** - Improve guides and examples
- **Testing** - Help validate releases
- **Feedback** - Share your experience and use cases

---

## Getting Started

### Choose Your Component

Listing Generator has three independent components:

- **[CLI](https://github.com/Max-Moro/lg-cli)** - Core context generation engine (Python)
- **[VS Code Extension](https://github.com/Max-Moro/lg-vscode)** - VS Code integration (TypeScript)
- **[IntelliJ Plugin](https://github.com/Max-Moro/lg-intellij)** - IntelliJ integration (Kotlin)

**You don't need to work with all three!** Most contributions affect only one component.

### Development Setup

**Single Component** (recommended for most contributions):
```bash
# Fork and clone component repo
git clone git@github.com:YOUR_USERNAME/lg-cli.git
cd lg-cli

# Follow component's README for setup
```

**Multi-Component** (for cross-component features):
```bash
# Clone federated repo
git clone --recurse-submodules git@github.com:Max-Moro/lg-federated.git
cd lg-federated
./scripts/setup-dev.sh
```

See [DEVELOPMENT.md](./DEVELOPMENT.md) for detailed workflow guidance.

---

## Reporting Issues

### Bug Reports

**Submit to appropriate repository:**
- CLI bugs → [lg-cli issues](https://github.com/Max-Moro/lg-cli/issues)
- VS Code bugs → [lg-vscode issues](https://github.com/Max-Moro/lg-vscode/issues)
- IntelliJ bugs → [lg-intellij issues](https://github.com/Max-Moro/lg-intellij/issues)
- Cross-component issues → [lg-federated issues](https://github.com/Max-Moro/lg-federated/issues)

**Include:**
- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, versions)
- Error messages or logs

### Feature Requests

**For general features** - Discuss in [lg-federated discussions](https://github.com/Max-Moro/lg-federated/discussions)

**For component-specific features** - Open issue in respective component repository

---

## Contributing Code

### 1. Find or Create an Issue

- Check existing issues to avoid duplicates
- For new features, discuss in issue first
- Get maintainer feedback before significant work

### 2. Fork and Branch

```bash
# Fork the repository on GitHub

# Clone your fork
git clone git@github.com:YOUR_USERNAME/<component>.git
cd <component>

# Create feature branch
git checkout -b feature/my-feature
```

### 3. Make Changes

Follow component-specific guidelines:
- **CLI**: See `cli/README.md` and `cli/CONTRIBUTING.md`
- **VS Code**: See `vscode/README.md`
- **IntelliJ**: See `intellij/README.md`

### 4. Commit Guidelines

Use clear, descriptive commit messages:

```
<type>: <subject>

<body>

<footer>
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `refactor:` - Code refactoring
- `test:` - Tests
- `chore:` - Build/tools

**Examples:**
```
feat: add support for Ruby language adapter

Implements basic Ruby adapter with class/method extraction
and comment handling.

Closes #123
```

```
fix: correct token counting for multiline strings

Previously multiline strings were counted incorrectly.

Fixes #456
```

### 5. Submit Pull Request

**Before submitting:**
- Follow component's code style
- Add/update tests (if applicable)
- Update documentation
- Update CHANGELOG.md under `[Unreleased]`

**Pull Request should include:**
- Clear description of changes
- Motivation and context
- Link to related issue(s)
- Screenshots for UI changes

**Submit PR to component repository**, not federated repo.

### 6. Code Review

- Maintainers will review within 3-5 business days
- Address feedback constructively
- Keep PR focused on single feature/fix
- Maintainer may request changes or suggest improvements

---

## Multi-Component Contributions

For features spanning CLI + IDE plugins:

**Workflow:**
1. Open issue in `lg-federated` to discuss approach
2. Get maintainer approval for cross-component changes
3. Start with CLI changes (establish API)
4. Open CLI PR and get it reviewed/approved
5. Open IDE plugin PRs (link to CLI PR)
6. Maintainer will coordinate merging

**Example:**
```
CLI PR #123: Add adaptive modes API
VS Code PR #45: Implement adaptive modes UI (depends on lg-cli#123)
IntelliJ PR #67: Implement adaptive modes UI (depends on lg-cli#123)
```

---

## Documentation Contributions

Documentation improvements are always welcome:

**What you can do:**
- Fix typos or unclear wording
- Add examples and tutorials
- Improve API documentation
- Add missing information

**Where to contribute:**
- Component docs → Component repository
- Ecosystem docs → `lg-federated/docs/`

---

## Questions and Support

- **General questions** - [GitHub Discussions](https://github.com/Max-Moro/lg-federated/discussions)
- **Technical issues** - Component issue trackers
- **Workflow questions** - See [DEVELOPMENT.md](./DEVELOPMENT.md)

---

## Recognition

Contributors are recognized in:
- Release notes
- Component CHANGELOG files
- GitHub contributor graphs

---

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.

---

Thank you for making Listing Generator better! 🎉
