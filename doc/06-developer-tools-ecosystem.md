# 🛠️ 06. Developer Tools Ecosystem (`bv tool`)

The BlaiseVue ecosystem provides a dedicated tooling manager (`bv tool`) designed specifically for developer tools, IDE extensions, CLI companions, and build utilities.

Unlike libraries in `packages/` (which are consumed inside your application's `lib/` directory via `bv lib`), developer tools operate on your environment or workflow and reside cleanly in `~/.blaisevue/tools/` or are pre-bundled in the framework.

---

## 🧭 1. Tool Classifications & Origins

Every developer tool discovered by the CLI is assigned a clear classification badge:

| Classification | Location | Description |
|---|---|---|
| **`[Built-in]`** | `packages/tools/` | Core framework tooling pre-bundled with BlaiseVue (`blaise-vscode`, `blaise-lazarus`, `blaise-devtools`). Protected against accidental deletion. |
| **`[Co-Official]`** | `~/.blaisevue/tools/` | Official ecosystem tools curated by the BlaiseVue team with the `blaise-*` prefix. Installed globally to keep the base framework repository compact. |
| **`[Third-Party]`** | `~/.blaisevue/tools/` | Community tools, custom plugins, and developer utilities installed from registered ecosystem repositories or external archives. |

---

## ⚡ 2. Core CLI Commands (`bv tool`)

```bash
# 1. List all installed tools with status, versions, and classifications:
bv tool list

# 2. Search available tools in registered ecosystem repositories:
bv tool search [term]

# 3. Inspect detailed technical card and lifecycle scripts of a tool:
bv tool info <tool-name>

# 4. Install a tool from the ecosystem with SemVer support:
bv tool install <tool-name>
bv tool install <tool-name>@^1.0.0
bv tool install official:<tool-name>@latest

# 5. Install directly from a local archive or remote URL:
bv tool install ./dist/my-tool-1.0.0.zip
bv tool install https://github.com/my-org/tools/releases/download/v1.0.0/my-tool.zip

# 6. Execute an installed tool CLI or entry script with argument forwarding:
bv tool run <tool-name> [arguments...]
bv tool exec <tool-name> [arguments...]

# 7. Check for available updates across all installed tools:
bv tool outdated

# 8. Update user tools to the latest versions found in ecosystem:
bv tool update [<tool-name>]

# 9. Uninstall a user tool cleanly with lifecycle script:
bv tool remove <tool-name>

# 10. Package a tool into a verified release archive (.zip with SHA-256):
bv tool pack [dir]

# 11. Scaffold a new tool project with manifest and lifecycle scripts:
bv tool init <tool-name> [--local]
```

---

## 🧩 3. Tool Package Anatomy (`tool.json`)

A developer tool contains a `tool.json` manifest at its root declaring metadata, entry executable, and lifecycle scripts:

```json
{
  "name": "my-developer-tool",
  "version": "1.0.0",
  "category": "Developer Tool",
  "description": "Comprehensive schema validator and code generator for BlaiseVue",
  "author": "Your Name <developer@example.com>",
  "license": "MIT",
  "homepage": "https://github.com/your-username/my-developer-tool",
  "type": "third-party",
  "bin": "run.py",
  "scripts": {
    "status": "status.py",
    "install": "install.py",
    "update": "update.py",
    "remove": "remove.py",
    "pack": "pack.py"
  }
}
```

### Manifest Fields:
- **`name`**: Tool identifier (lowercase alphanumeric, hyphens).
- **`version`**: Semantic Versioning string (`MAJOR.MINOR.PATCH`).
- **`bin`** / **`exec`** / **`main`**: Entry point executable or script executed via `bv tool run`.
- **`type`**: Tool origin (`co-official` or `third-party`).
- **`scripts`**: Object containing lifecycle hook script paths.

---

## 📁 4. Supported Directory Layout

A tool package can include documentation (`doc/`) and runnable examples (`examples/`):

```text
my-developer-tool/
├── tool.json          # Manifest with version, category, bin, and scripts
├── README.md          # Tool documentation and user guide
├── run.py             # Main CLI executable (invoked via "bv tool run my-developer-tool")
├── doc/               # Extended architecture, manuals, and technical references
│   ├── 01-architecture.md
│   └── 02-configuration.md
├── examples/          # Sample configurations, scripts, and demo inputs
│   └── sample-config.json
├── status.py          # Status reporting hook
├── install.py         # Installation hook
├── update.py          # Update hook
├── remove.py          # Cleanup hook
└── pack.py            # Custom packaging script (optional)
```

---

## 🚀 5. Executing Tools Directly (`bv tool run`)

BlaiseVue allows any installed tool to be executed directly from anywhere on your terminal:

```bash
# Basic tool invocation:
bv tool run my-developer-tool

# Passing CLI flags, files, and arguments:
bv tool run my-developer-tool --schema ./models/User.pas --verbose
```

### Auto-Detection Heuristics:
If the `tool.json` does not explicitly declare a `"bin"` property, the runner automatically detects:
1. Native binaries: `<tool-name>.exe` or `<tool-name>` in the root or `bin/` directory.
2. Python scripts: `run.py` or `main.py`.
3. InstantFPC Pascal scripts: `run.pas`.
4. Node.js scripts: `cli.js` or `index.js`.

The CLI forwards all passed arguments and preserves process exit codes.

---

## 🔄 6. Tool Lifecycle Scripts

Tools support cross-platform lifecycle hooks written in Python (`.py`), InstantFPC (`.pas`), or native binaries:

### 1. Status Hook (`status.py` / `status.pas`)
Invoked by `bv tool list`. Must print a single concise line describing the tool's live status:
```python
#!/usr/bin/env python3
print("Active (v1.0.0) - Connected to local engine")
```

### 2. Install Hook (`install.py` / `install.pas`)
Invoked by `bv tool install` right after unzipping the tool. Configures environment variables, downloads binaries, or builds assets:
```python
#!/usr/bin/env python3
print("Configuring my-developer-tool dependencies...")
print("Installation completed.")
```

### 3. Update Hook (`update.py` / `update.pas`)
Invoked by `bv tool update`. Handles data migrations or updates binary components.

### 4. Remove Hook (`remove.py` / `remove.pas`)
Invoked by `bv tool remove` before removing the tool directory. Cleans up caches, unregisters system services, or removes temporary files.

---

## 🏷️ 7. Publishing Tools in `ecosystem.json`

To make your tool installable by the community, submit it to `ecosystem.json` in the `blaisevue-ecosystem` repository under the `"tools"` section:

```json
{
  "name": "blaisevue-ecosystem",
  "description": "Official community ecosystem, library registry and developer tools for BlaiseVue",
  "version": "1.0.0",
  "packages": { ... },
  "tools": {
    "my-developer-tool": {
      "name": "my-developer-tool",
      "type": "third-party",
      "category": "Code Quality",
      "description": "Schema validator and code generator for BlaiseVue",
      "latest": "1.0.0",
      "versions": [
        {
          "version": "1.0.0",
          "download_url": "https://github.com/your-org/my-developer-tool/releases/download/v1.0.0/my-developer-tool-1.0.0.zip",
          "checksum": "a3b2c1..."
        }
      ]
    }
  }
}
```

---

## 🩺 8. Diagnostic Health Check (`bv doctor`)

The BlaiseVue environment diagnostic suite automatically monitors your developer tools ecosystem:

```text
[2] Ecosystem & Testing Tools:
  [v] Python 3:             v3.13.12 (system PATH, recommended for tool packages)
  [v] Node.js & npm:        Node v24.12.0 and npm v11.11.0 detected in PATH
  [!] Docker CLI:           Not detected (Optional: production micro-containers)
  [v] Developer Tools:      3 tools active (3 built-in, 0 user tools in ~/.blaisevue/tools)
```

If any tool encounters missing files or corrupt manifests, `bv doctor` alerts you immediately with actionable troubleshooting tips.
