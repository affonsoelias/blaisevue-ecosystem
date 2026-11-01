# BlaiseVue Ecosystem & Registry 🌐

Official multi-package ecosystem repository and extensions registry for [BlaiseVue](https://github.com/affonsoelias/BlaiseVue).

---

## 📦 About

This repository hosts official community wrappers, heavyweight graphics engines (Three.js, Plotly.js, Leaflet, etc.), and optional enterprise plugins for BlaiseVue, preventing repository bloat and keeping the core framework lean.

---

## 📚 Documentation & Guides (`doc/`)

Explore the comprehensive guides on using, developing, and publishing packages:

| Guide | Description |
|---|---|
| 🚀 [**01. Getting Started & Usage**](doc/01-getting-started.md) | How to search, install, update, and manage ecosystem packages with BlaiseVue CLI. |
| 🧩 [**02. Package Anatomy**](doc/02-package-anatomy.md) | Standard file structure, `package.json`, Pascal units, `.bv` components, and `setup.pas`. |
| 🛠️ [**03. Creating a New Package**](doc/03-creating-packages.md) | Step-by-step library scaffolding (`bv create --lib`), HMR sandbox development, and tests. |
| 📦 [**04. Packaging, Publishing & Examples**](doc/04-packaging-and-publishing.md) | Packaging with `bv lib pack`, GitHub Releases convention (`<pkg>@<ver>`), submitting to `ecosystem.json`, and contributing examples. |
| 🌐 [**05. Custom & Private Registries**](doc/05-custom-registries.md) | How to host and connect custom corporate registries with `bv repo add`. |

---

## 💡 Runnable Examples (`examples/`)

Explore the [`examples/`](examples/README.md) directory to find complete, runnable BlaiseVue demo projects demonstrating how to consume ecosystem packages in real-world applications.

---

## 🚀 Quick CLI Usage

```bash
# 1. Search for available packages:
bv lib search

# 2. Install latest version into current project:
bv lib install test

# 3. Install a pinned version:
bv lib install test@1.0.0

# 4. Install into global offline cache:
bv lib install test --global

# 5. Check for outdated packages:
bv lib outdated

# 6. Upgrade installed packages:
bv lib update
```

---

## 📋 Available Packages

| Package | Latest Version | Description | Examples & Demos |
|---|---|---|---|
| `test` | `1.1.0` | Verification and testing package for the registry | [View Guide](doc/01-getting-started.md) |

---

## 🤝 Contributing

Contributions are welcome! Please read [Packaging, Publishing & Examples](doc/04-packaging-and-publishing.md) for guidelines on submitting new packages, runnable examples, and documentation via Pull Request.
