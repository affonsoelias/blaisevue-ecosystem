# BlaiseVue Ecosystem Tools 🛠️

This directory hosts co-official developer tools, utilities, and extensions maintained in the BlaiseVue ecosystem.

Unlike libraries in `packages/` (managed via `bv lib`), tools in this directory are managed using the dedicated tool manager:

```bash
# List all installed tools (built-in and user tools)
bv tool list

# Search available tools in the ecosystem
bv tool search [term]

# View detailed technical information about a tool
bv tool info <tool-name>

# Install a tool from ecosystem or archive into ~/.blaisevue/tools/
bv tool install <tool-name>
bv tool install <url|archive.zip>

# Run an installed developer tool CLI or entry script directly
bv tool run <tool-name> [args...]

# Check for newer versions available across installed tools
bv tool outdated

# Update user tools to the latest version
bv tool update [<tool-name>]

# Uninstall a tool from ~/.blaisevue/tools/
bv tool remove <tool-name>

# Package a tool into a distributable archive (.zip with SHA-256)
bv tool pack [dir]

# Scaffold a new tool project with tool.json and lifecycle scripts
bv tool init <tool-name>
```

---

## Tool Anatomy (`tool.json`)

Every tool package defines a `tool.json` manifest at its root:

```json
{
  "name": "my-developer-tool",
  "version": "1.0.0",
  "category": "Developer Tool",
  "description": "Clear and concise description in English",
  "author": "Author Name",
  "license": "MIT",
  "homepage": "https://github.com/...",
  "type": "co-official",
  "scripts": {
    "status": "status.py",
    "install": "install.py",
    "update": "update.py",
    "remove": "remove.py",
    "pack": "pack.py"
  }
}
```

### Supported Directory Layout

A tool or library package can include documentation and runnable examples:

```
my-developer-tool/
├── tool.json          # Package manifest & lifecycle hooks
├── README.md          # Tool documentation & quick start
├── doc/               # Extended architecture, guides, and manuals
│   └── 01-overview.md
├── examples/          # Sample scripts, configurations, and test cases
│   └── example-config.json
├── status.py          # Status reporting script (status.py or status.pas)
├── install.py         # Lifecycle install hook
├── update.py          # Lifecycle update hook
└── remove.py          # Lifecycle cleanup hook
```
