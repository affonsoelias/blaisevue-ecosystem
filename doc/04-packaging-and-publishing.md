# 📦 04. Packaging, Releases & Publishing

This guide explains the end-to-end workflow to package your library, publish release binaries on GitHub Releases, and submit your package to the official `blaisevue-ecosystem` catalog.

---

## 📦 1. Packaging the Library (`bv lib pack`)

When your library is ready for distribution, run the packaging command at the package root:

```bash
bv lib pack
# or using the alias:
bv lib dist
```

### What the command does:
1. **Pre-flight Tests**: Automatically runs `bv test`. If any test fails, packaging is aborted immediately to prevent distributing defective releases.
2. **Production Pruning**: Excludes non-essential directories and build artifacts (`.git`, `node_modules`, compilation files `.o`, `.ppu`, `.tmp`).
3. **ZIP Archive Generation**: Creates the compressed distribution bundle in `dist/<name>-<version>.zip`.
4. **Integrity Checksum (SHA-256)**: Computes the cryptographic checksum in `dist/<name>-<version>.zip.sha256`.

> **Tip**: To skip test execution during rapid local builds, pass the `--skip-tests` flag:
> ```bash
> bv lib pack --skip-tests
> ```

---

## 🏷️ 2. Creating GitHub Releases

The BlaiseVue ecosystem uses prefixed tags to support both dedicated single-package repositories and multi-package monorepositories.

### Tagging Convention:
- Tag Pattern: `<package-name>@<version>`
- Example: `test@1.0.0`, `my-widget@2.1.0`

### Publishing via GitHub CLI (`gh`):
```bash
gh release create "my-widget@1.0.0" dist/my-widget-1.0.0.zip \
  --title "my-widget v1.0.0" \
  --notes "First official release of my-widget with reactive chart components."
```

Alternatively, visit the **Releases** tab of your GitHub repository, click **Draft a new release**, specify the tag `my-widget@1.0.0`, and upload `dist/my-widget-1.0.0.zip`.

---

## 🌐 3. Registering the Package in `ecosystem.json`

To allow developers worldwide to install your package via `bv lib install my-widget`, add your package entry to `ecosystem.json` in the `blaisevue-ecosystem` repository:

```json
{
  "name": "blaisevue-ecosystem",
  "description": "Official community ecosystem and library registry for BlaiseVue",
  "version": "1.0.0",
  "packages": {
    "my-widget": {
      "name": "my-widget",
      "description": "Reactive chart and dashboard components for BlaiseVue",
      "latest": "1.0.0",
      "versions": ["1.0.0"],
      "download": "https://github.com/your-username/your-repo/releases/download/{tag}/{package}-{version}.zip"
    }
  }
}
```

### Download Template Placeholders:
- `{tag}` $\rightarrow$ Substituted with the matching Git tag (e.g., `my-widget@1.0.0`)
- `{package}` $\rightarrow$ Package identifier (e.g., `my-widget`)
- `{version}` $\rightarrow$ Target SemVer version (e.g., `1.0.0`)

---

## 📖 4. Providing Documentation & Runnable Examples

To deliver the best developer experience, package authors are encouraged to contribute documentation and runnable examples directly to the `blaisevue-ecosystem` repository alongside their `ecosystem.json` submission:

### 1. In-Package Documentation (Bundled in Release `.zip`)
Every library scaffolded with `bv create <name> --lib` contains:
- **`README.md`**: Explains installation, component props, events, and API reference. This file is bundled inside the distributed `.zip` and extracted into the consumer's `lib/<package>/` folder.
- **`demo/` Sandbox**: Contains a runnable playground (`index.html` and `App.bv`) allowing users or contributors to test components in isolation.

### 2. Ecosystem Repository Documentation (`doc/packages/<name>.md`)
For extensive component libraries, authors can submit a dedicated markdown documentation page in `doc/packages/<name>.md` within the `blaisevue-ecosystem` repository. This page can include:
- Interactive code walkthroughs and component showcases.
- Pascal unit interface documentation (types, classes, methods).
- Live screenshots, animated GIFs, and architectural diagrams.

### 3. Community Runnable Examples (`examples/<package>/`)
Authors can contribute complete, runnable BlaiseVue demo projects showcasing their package inside `examples/<package>/`:
- Each example is a standalone BlaiseVue project configured to consume the package.
- Developers can clone the repository, navigate to `examples/<package>/`, and immediately run `bv dev` to see the library in action.
- Links to these examples are placed in the root `README.md` package catalog table.

---

## 🛡️ 5. Naming Guidelines & Core Reserved Names

To protect framework integrity and eliminate typosquatting or namespace hijacking across the ecosystem:

### Reserved Names Policy
- **Prefix `blaise-`**: Any package name beginning with `blaise-` (case-insensitive) is strictly reserved for official BlaiseVue framework components and ecosystem modules.
- **Core Module Names**: The following names are reserved and cannot be claimed by third-party packages:
  `ui`, `themes`, `icons`, `charts`, `reports`, `studio`, `mobile`, `core`, `sdk`, `tools`, `pas2js`, `framework`, `std`, and `runtime`.

### Community Recommendations
Community authors are encouraged to use descriptive package names, prefixes, or organizational scopes:
- ✅ **Allowed**: `my-charts`, `ui-custom`, `vasco-ui`, `acme-auth`, `awesome-grid`.
- ❌ **Rejected**: `ui`, `blaise-ui`, `blaise-awesome` (will be rejected automatically by `bv create --lib` and Pull Request verification).

---

## 🚀 6. Submitting via Pull Request

1. Fork the [`blaisevue-ecosystem`](https://github.com/affonsoelias/blaisevue-ecosystem) repository.
2. Add your package manifest entry into `ecosystem.json`.
3. (Optional) Add your runnable demo to `examples/<package>/` and documentation to `doc/packages/<package>.md`.
4. Submit a Pull Request targeting the `main` branch.
5. Once merged, every BlaiseVue developer will discover and receive your package upon running `bv repo sync`!
