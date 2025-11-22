# Implementation Plan: Two-Mode CLI Resolution System

## Overview

Refactor both IDE plugins (VS Code and IntelliJ) to support exactly two modes:

1. **User Mode** (Default) - Auto-managed pipx installation with version pinning
2. **Developer Mode** - Manual Python interpreter for testing unreleased CLI

## Goals

- **Simplify** CLI resolution logic (remove complex fallback chains)
- **Pin versions** in User Mode for stability (e.g., `listing-generator==0.9.0`)
- **Streamline** Developer Mode for CLI development workflow
- **Remove** unused/overengineered features (managed venv, system strategy, etc.)

---

## Architecture Changes

### User Mode (Default)

**Characteristics:**
- Uses **pipx** to install CLI globally from PyPI
- Version is **pinned** to match plugin version (e.g., `^0.9.0`)
- **Auto-installs** on first run if missing
- **Auto-upgrades** to latest compatible patch version
- **Zero configuration** required from user

**Resolution Logic:**
```
1. Check if `listing-generator` exists in PATH
2. If missing: Install with pipx (pinned version)
3. If exists but wrong version: Upgrade with pipx
4. Return path to `listing-generator` command
```

**Implementation Requirements:**
- Add CLI version constant synchronized with plugin version
- Implement pipx installation wrapper
- Implement version detection and comparison
- Add upgrade prompts/automatic upgrades
- Remove all managed venv code

### Developer Mode

**Characteristics:**
- Uses **Python interpreter** from settings pointing to CLI dev venv
- Runs CLI as module: `python -m lg.cli`
- **Manual configuration** required (point to CLI repo's `.venv/python`)
- **No auto-install** or version management

**Resolution Logic:**
```
1. Check if Python interpreter is configured in settings
2. If configured: Return `{cmd: python, args: ["-m", "lg.cli"]}`
3. If not configured: Show error with instructions
```

**Implementation Requirements:**
- Add "Developer Mode" toggle in settings
- Show Python interpreter field only when enabled
- Simplify resolver to skip all fallback logic
- Add clear error messages guiding setup

---

## VS Code Extension Changes

### Phase 1: Add Version Management Infrastructure

**File: `vscode/src/constants.ts` (NEW)**
```typescript
/**
 * CLI version that this extension is compatible with.
 * Should match extension version in package.json.
 *
 * Format: Semantic versioning (e.g., "0.9.0")
 * Compatibility: ^0.9.0 means >=0.9.0 <0.10.0
 */
export const CLI_VERSION = "0.9.0";

/**
 * PyPI package name for Listing Generator CLI
 */
export const PYPI_PACKAGE = "listing-generator";
```

**File: `vscode/package.json`**
- Update configuration schema:
  - Remove `lg.install.strategy` (no longer needed)
  - Add `lg.developerMode` (boolean, default: false)
  - Keep `lg.python.interpreter` (only used in developer mode)
  - Remove `lg.cli.path` (replaced by pipx installation)

### Phase 2: Implement pipx Installation

**File: `vscode/src/runner/PipxInstaller.ts` (NEW)**
```typescript
/**
 * Manages pipx-based CLI installation for User Mode.
 */
export class PipxInstaller {
  /**
   * Ensures CLI is installed via pipx with correct version.
   *
   * @returns Path to installed CLI or throws error
   */
  async ensureCli(): Promise<string>;

  /**
   * Checks if pipx is available on the system.
   */
  async isPipxAvailable(): Promise<boolean>;

  /**
   * Installs CLI with pinned version using pipx.
   */
  async install(): Promise<void>;

  /**
   * Upgrades CLI to latest compatible version.
   */
  async upgrade(): Promise<void>;

  /**
   * Checks installed CLI version.
   */
  async getInstalledVersion(): Promise<string | null>;
}
```

### Phase 3: Simplify CLI Resolver

**File: `vscode/src/cli/CliResolver.ts`**
```typescript
async function resolveCliRunSpec(): Promise<RunSpec> {
  const config = vscode.workspace.getConfiguration();
  const isDeveloperMode = config.get<boolean>("lg.developerMode");

  if (isDeveloperMode) {
    // Developer Mode: Use configured Python interpreter
    return resolveDeveloperMode(config);
  } else {
    // User Mode: Use pipx-installed CLI
    return resolveUserMode();
  }
}

function resolveDeveloperMode(config): RunSpec {
  const pythonPath = config.get<string>("lg.python.interpreter");

  if (!pythonPath || !pythonPath.trim()) {
    throw new Error(
      "Developer Mode requires Python interpreter. " +
      "Configure 'lg.python.interpreter' in Settings."
    );
  }

  if (!fs.existsSync(pythonPath)) {
    throw new Error(`Python interpreter not found: ${pythonPath}`);
  }

  return {
    cmd: pythonPath,
    args: ["-m", "lg.cli"]
  };
}

async function resolveUserMode(): Promise<RunSpec> {
  const installer = new PipxInstaller();

  // Ensure pipx is available
  if (!(await installer.isPipxAvailable())) {
    // Offer to install pipx or switch to developer mode
    throw new Error("pipx not found. Install pipx or enable Developer Mode.");
  }

  // Ensure CLI is installed with correct version
  const cliPath = await installer.ensureCli();

  return {
    cmd: cliPath,
    args: []
  };
}
```

### Phase 4: Remove Obsolete Code

**Files to DELETE:**
- `vscode/src/runner/LgInstaller.ts` (managed venv no longer used)

**Files to MODIFY:**
- `vscode/src/runner/PythonFind.ts` (keep for developer mode only)

### Phase 5: Update Settings UI

**File: `vscode/package.json`**
```json
{
  "configuration": {
    "properties": {
      "lg.developerMode": {
        "type": "boolean",
        "default": false,
        "description": "Enable Developer Mode for testing unreleased CLI versions"
      },
      "lg.python.interpreter": {
        "type": "string",
        "default": "",
        "description": "[Developer Mode Only] Path to Python interpreter in CLI repository venv"
      }
    }
  }
}
```

---

## IntelliJ Plugin Changes

### Phase 1: Add Version Management Infrastructure

**File: `intellij/src/main/kotlin/lg/intellij/cli/CliVersion.kt` (NEW)**
```kotlin
package lg.intellij.cli

/**
 * CLI version management for Listing Generator plugin.
 */
object CliVersion {
    /**
     * CLI version that this plugin is compatible with.
     * Should match plugin version in gradle.properties.
     *
     * Format: Semantic versioning (e.g., "0.9.0")
     * Compatibility: ^0.9.0 means >=0.9.0 <0.10.0
     */
    const val REQUIRED_VERSION = "0.9.0"

    /**
     * PyPI package name for Listing Generator CLI.
     */
    const val PYPI_PACKAGE = "listing-generator"

    /**
     * Version constraint for pip install (caret range).
     * ^0.9.0 means >=0.9.0 <0.10.0
     */
    fun getVersionConstraint(): String {
        val parts = REQUIRED_VERSION.split(".")
        val major = parts[0]
        val minor = parts[1]
        val nextMinor = minor.toInt() + 1

        return ">=$REQUIRED_VERSION,<$major.$nextMinor.0"
    }
}
```

### Phase 2: Implement pipx Installation

**File: `intellij/src/main/kotlin/lg/intellij/cli/PipxInstaller.kt` (NEW)**
```kotlin
package lg.intellij.cli

import com.intellij.execution.configurations.GeneralCommandLine
import com.intellij.execution.process.CapturingProcessHandler
import com.intellij.openapi.components.Service
import com.intellij.openapi.diagnostic.logger

/**
 * Manages pipx-based CLI installation for User Mode.
 */
@Service(Service.Level.APP)
class PipxInstaller {

    private val log = logger<PipxInstaller>()

    /**
     * Ensures CLI is installed via pipx with correct version.
     *
     * @return Path to installed CLI
     * @throws CliNotFoundException if pipx is not available
     */
    suspend fun ensureCli(): String {
        // Implementation
    }

    /**
     * Checks if pipx is available on the system.
     */
    suspend fun isPipxAvailable(): Boolean {
        // Implementation
    }

    /**
     * Installs CLI with version constraint using pipx.
     */
    suspend fun install(): Unit {
        // Implementation
    }

    /**
     * Upgrades CLI to latest compatible version.
     */
    suspend fun upgrade(): Unit {
        // Implementation
    }

    /**
     * Checks installed CLI version.
     */
    suspend fun getInstalledVersion(): String? {
        // Implementation
    }
}
```

### Phase 3: Simplify CLI Resolver

**File: `intellij/src/main/kotlin/lg/intellij/cli/CliResolver.kt`**
```kotlin
private fun resolveInternal(): CliRunSpec {
    val settings = service<LgSettingsService>()

    return if (settings.state.developerMode) {
        resolveDeveloperMode(settings)
    } else {
        resolveUserMode()
    }
}

private fun resolveDeveloperMode(settings: LgSettingsService): CliRunSpec {
    val pythonPath = settings.state.pythonInterpreter?.trim() ?: ""

    if (pythonPath.isEmpty()) {
        throw CliNotFoundException(
            "Developer Mode requires Python interpreter. " +
            "Configure it in Settings > Tools > Listing Generator."
        )
    }

    if (!File(pythonPath).exists()) {
        throw CliNotFoundException("Python interpreter not found: $pythonPath")
    }

    return CliRunSpec(
        cmd = pythonPath,
        args = listOf("-m", "lg.cli")
    )
}

private fun resolveUserMode(): CliRunSpec {
    val installer = service<PipxInstaller>()

    // Check if pipx is available
    runBlocking {
        if (!installer.isPipxAvailable()) {
            throw CliNotFoundException(
                "pipx not found. Install pipx or enable Developer Mode in Settings."
            )
        }
    }

    // Ensure CLI is installed with correct version
    val cliPath = runBlocking { installer.ensureCli() }

    return CliRunSpec(cmd = cliPath)
}
```

### Phase 4: Update Settings Service

**File: `intellij/src/main/kotlin/lg/intellij/services/state/LgSettingsService.kt`**
```kotlin
class State : BaseState() {
    /** Developer Mode toggle */
    var developerMode by property(false)

    /** Python interpreter path (Developer Mode only) */
    var pythonInterpreter by string("")

    /** AI provider ID for "Send to AI" action */
    var aiProvider by string("")

    /** Open generated files as editable */
    var openAsEditable by property(false)
}
```

**Remove:**
- `cliPath` field (replaced by pipx)
- `installStrategy` enum and field

### Phase 5: Update Settings UI

**File: `intellij/src/main/kotlin/lg/intellij/settings/LgSettingsConfigurable.kt`**
```kotlin
override fun createPanel(): DialogPanel = panel {
    group(LgBundle.message("settings.group.cli")) {
        row {
            checkBox(LgBundle.message("settings.developer.mode.label"))
                .bindSelected(settings.state::developerMode)
        }.comment(LgBundle.message("settings.developer.mode.comment"))

        row(LgBundle.message("settings.python.interpreter.label")) {
            textFieldWithBrowseButton(
                FileChooserDescriptorFactory.singleFile()
                    .withTitle(LgBundle.message("settings.python.interpreter.browse.title"))
            ).bindText(
                getter = { settings.state.pythonInterpreter ?: "" },
                setter = { settings.state.pythonInterpreter = it }
            ).comment(LgBundle.message("settings.python.interpreter.comment"))
        }.visibleIf(settings.state::developerMode.toBinding())
    }

    // ... rest of settings ...
}
```

### Phase 6: Remove Obsolete Code

**Remove from `CliResolver.kt`:**
- `findInPath()` method
- `findPython()` method
- `isPythonValid()` method
- All fallback logic

**Update resource bundle:**
- Remove install strategy related messages
- Add developer mode related messages

---

## Version Pinning Strategy

### Synchronization Between Plugin and CLI

**VS Code Extension:**
```typescript
// vscode/src/constants.ts
export const CLI_VERSION = "0.9.0";  // Must match package.json version

// vscode/package.json
{
  "version": "0.9.0"
}
```

**IntelliJ Plugin:**
```kotlin
// intellij/src/main/kotlin/lg/intellij/cli/CliVersion.kt
object CliVersion {
    const val REQUIRED_VERSION = "0.9.0"  // Must match gradle.properties
}

// intellij/gradle.properties
pluginVersion = 0.9.0
```

### Version Constraint Format

**For pip install:**
```bash
# Install exact version
pip install listing-generator==0.9.0

# Or with caret range (recommended)
pip install "listing-generator>=0.9.0,<0.10.0"
```

**For pipx install:**
```bash
# Install with version constraint
pipx install "listing-generator>=0.9.0,<0.10.0"

# Upgrade within constraint
pipx upgrade listing-generator
```

### Version Checking Logic

```typescript
// VS Code
async function ensureCli(): Promise<string> {
  const installedVersion = await getInstalledVersion();

  if (!installedVersion) {
    await install(); // First install: >=0.9.0,<0.10.0
  } else if (!isVersionCompatible(installedVersion)) {
    await upgrade(); // Incompatible: 0.8.x → reinstall with ^0.9.0
  } else if (shouldCheckForUpdates()) {
    // Check for patch updates every 24 hours
    await upgrade(); // 0.9.0 → 0.9.1 (if available)
  }

  return cliPath;
}

function shouldCheckForUpdates(): boolean {
  if (lastUpdateCheck === null) return true; // Never checked
  const elapsed = Date.now() - lastUpdateCheck;
  return elapsed >= 24 * 60 * 60 * 1000; // 24 hours
}
```

**Auto-update features:**
- ✅ Checks for patch updates every 24 hours (in-memory cache)
- ✅ Immediately upgrades incompatible versions
- ✅ Force update via IDE restart (clears cache)
- ✅ No persistent storage - clean slate on each restart

---

## Migration Guide for Users

### VS Code Users

**Before (v0.8.x):**
- Multiple install strategies to choose from
- Manual configuration of CLI path or Python interpreter
- Managed venv created by extension

**After (v0.9.0):**
- **Auto-install**: CLI installs automatically via pipx on first run
- **Zero config**: No settings needed for normal use
- **Developer Mode**: Enable only if testing unreleased CLI versions

**Migration Steps:**
1. Update extension to v0.9.0
2. Extension will prompt to install pipx (if not present)
3. Extension auto-installs compatible CLI version
4. Old settings are ignored (no breaking changes)

### IntelliJ Users

**Before (v0.8.x):**
- Install strategy selection (non-functional managed venv)
- Manual CLI path configuration
- Manual Python interpreter configuration

**After (v0.9.0):**
- **Auto-install**: CLI installs automatically via pipx on first run
- **Zero config**: No settings needed for normal use
- **Developer Mode**: Enable in Settings for CLI development

**Migration Steps:**
1. Update plugin to v0.9.0
2. Plugin will prompt to install pipx (if not present)
3. Plugin auto-installs compatible CLI version
4. Old settings are removed (clean slate)

---

## Documentation Updates

### Files to Update

1. **VS Code Extension:**
   - `vscode/README.md` - Remove install strategy mentions, add Developer Mode
   - `vscode/CHANGELOG.md` - Add migration notes

2. **IntelliJ Plugin:**
   - `intellij/README.md` - Remove install strategy mentions, add Developer Mode
   - `intellij/CHANGELOG.md` - Add migration notes

3. **Federated Repository:**
   - `DEVELOPMENT.md` - Update developer workflow
   - `VERSIONING.md` - Clarify version pinning strategy
   - `CONTRIBUTING.md` - Update setup instructions

### Key Message for Documentation

> **Simplified Installation (v0.9.0+)**
>
> Listing Generator now auto-installs via pipx with zero configuration required.
>
> **For Users:**
> - Install VS Code extension or IntelliJ plugin
> - Extension auto-installs compatible CLI on first run
> - No manual setup needed
>
> **For Developers:**
> - Enable "Developer Mode" in Settings
> - Point to your CLI repository's Python interpreter
> - Test unreleased features seamlessly

---

## Testing Checklist

### User Mode Testing

- [ ] Fresh install with no CLI present
- [ ] Auto-install via pipx works
- [ ] Version detection works correctly
- [ ] Upgrade prompt appears for outdated CLI
- [ ] Auto-upgrade works
- [ ] Error handling when pipx is missing
- [ ] Error messages are clear and actionable

### Developer Mode Testing

- [ ] Enable Developer Mode in Settings
- [ ] Configure Python interpreter
- [ ] CLI resolves to Python module
- [ ] Runs with `-m lg.cli` correctly
- [ ] Error when Python interpreter not set
- [ ] Error when Python interpreter invalid
- [ ] Switching between modes works

### Cross-Platform Testing

- [ ] Windows (pipx installation path resolution)
- [ ] macOS (pipx installation path resolution)
- [ ] Linux (pipx installation path resolution)

### Version Management Testing

- [ ] Correct version installed on first run
- [ ] Version mismatch detected
- [ ] Upgrade prompt shown
- [ ] Downgrade prevented (or warned)

---

## Implementation Timeline

### Week 1: VS Code Extension

- [ ] Day 1-2: Add version constants, create pipx installer
- [ ] Day 3-4: Refactor CLI resolver, remove managed venv
- [ ] Day 5: Update settings UI, testing

### Week 2: IntelliJ Plugin

- [ ] Day 1-2: Add version constants, create pipx installer
- [ ] Day 3-4: Refactor CLI resolver, update settings
- [ ] Day 5: Update settings UI, testing

### Week 3: Documentation & Polish

- [ ] Update all documentation
- [ ] Cross-platform testing
- [ ] Migration guide
- [ ] Release preparation

---

## Success Criteria

1. **User Mode**: Zero-config installation works on all platforms
2. **Developer Mode**: Clear setup instructions, works with CLI dev venv
3. **Version Management**: Auto-detects and upgrades within compatibility range
4. **Code Quality**: Simplified resolver logic, removed dead code
5. **Documentation**: Clear migration guide, updated workflow docs
6. **Testing**: All test cases pass on Windows, macOS, Linux

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| pipx not available on user's system | High | Clear error message with install instructions, fallback to Developer Mode |
| Version constraint too strict | Medium | Use caret range (^0.9.0) to allow patch updates |
| Breaking change for existing users | High | Auto-migration, preserve old settings temporarily |
| Platform-specific pipx behavior | Medium | Thorough cross-platform testing |
| Developer Mode setup unclear | Low | Detailed documentation with screenshots |

---

This plan provides a complete roadmap for implementing the two-mode system across both IDE plugins.
