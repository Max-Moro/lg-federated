# Parallel Development Mode

We are currently working in a **federated repository**.

```
lg/               → We are here (repository root)
├── cli/          → Core engine (Python)
├── vscode/       → VS Code integration (TypeScript)
├── intellij/     → IntelliJ integration (Kotlin)
├── lg-cfg/       → Example configuration
├── docs/         → Documentation
└── scripts/      → Development utilities
```

The federated repository has 3 Git submodules — directly linked subprojects.

| Component | Description | Repository | Distribution |
|-----------|-------------|------------|--------------|
| **CLI** | Core context generation engine | [lg-cli](https://github.com/Max-Moro/lg-cli) | PyPI |
| **VS Code Extension** | Interactive UI for VS Code | [lg-vscode](https://github.com/Max-Moro/lg-vscode) | VS Code Marketplace |
| **IntelliJ Plugin** | Interactive UI for JetBrains IDEs | [lg-intellij](https://github.com/Max-Moro/lg-intellij) | JetBrains Marketplace |

## Working Directory Context

All standard tools and `bash` commands will execute in the **federated repository root** by default. If you need to do something specifically in the `vscode/` or `intellij/` subprojects, you must first change to that directory.

## When to Use Parallel Development

Some tasks and feature blocks are more convenient to develop simultaneously across both IDE plugins. This is especially true when:
- Implementing new business requirements
- Working on features not tied to internal platform-specific technical details of **VS Code** or **IntelliJ**

In such cases, all intermediate documentation artifacts should be planned in a **generalized form**:
- Technical specification and business requirements formulation
- Architecture planning and refactoring design
- Development roadmap creation

## Development Process

The actual development (writing code) at each stage should happen **in parallel**, with constant switching between `vscode/` and `intellij/` projects.

### Typical Workflow

1. **Plan** the feature/change in a generalized way
2. **Prepare instructions** for @code-integrator covering both platforms
3. **Integrate code** via @code-integrator (modifies both vscode/ and intellij/)
4. **Compile** via @compiler (checks both projects)
5. **Report** to user and await manual testing feedback

## Working with Subagents

In parallel development mode, the following agents are available:

| Agent | Purpose |
|-------|---------|
| @code-integrator | Integrates code into vscode/ and intellij/ based on detailed instructions |
| @compiler | Checks compilation of both projects, fixes errors |

### Agent Invocation Order

1. Plan changes for both platforms (architecture, data models, UI)
2. Prepare comprehensive instructions including code for both TypeScript and Kotlin
3. @code-integrator — pass instructions covering vscode/ and intellij/ code
4. @compiler — verify both projects compile successfully

### Code Integration Instructions

When preparing instructions for @code-integrator, include:
- Brief business requirements
- Required architecture changes (if any)
- Integration points for new functionality
- **Code listings for both platforms** as fenced code blocks
- Patch descriptions (can be informal but clear)
- **When changing public APIs** — explicit indication of ALL files using these functions/types

### Testing and Inspections

**Important**: Automated tests and code inspections are **NOT run** in parallel development mode.

Reason: Each platform has its own specific technology stack, and running platform-specific tests would require separate workflows.

Testing is performed **manually by the developer** after each development iteration:
- VS Code: Run Extension Development Host (F5) and verify UI logic
- IntelliJ: Run Development Instance and verify UI logic

## Git Workflow

When making intermediate or final commits, you must actually make **2 commits**: one in `vscode/` repository and one in `intellij/` repository.

Before committing, verify that both subprojects are on **identically named branches**.

### Branch Verification

```bash
# Check current branches in all subprojects
cd vscode && git branch --show-current && cd ..
cd intellij && git branch --show-current && cd ..
```

### Creating Feature Branches

Use the federated repository script to create branches across all submodules:

```bash
./scripts/create-branch.sh feature/my-feature
```

### Commit Process

```bash
# Commit in VS Code subproject
cd vscode
git add .
git commit -m "feat: implement provider selector UI"
cd ..

# Commit in IntelliJ subproject
cd intellij
git add .
git commit -m "feat: implement provider selector UI"
cd ..

# Update federated repo submodule references (optional)
git add vscode intellij
git commit -m "Update submodules: implement provider selector UI"
```

## Error Handling

If code compiles in one subproject but fails in the other:

1. **Report** the discrepancy to the user
2. **Do not commit** until the issue is resolved
3. The architectural solution may need **platform-specific adaptation**

Escalate to the user when:
- Fixing requires major refactoring beyond scope
- Business logic is unclear
- Platform-specific constraints prevent unified implementation
