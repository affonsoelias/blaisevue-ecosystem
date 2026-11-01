# 📚 BlaiseVue Ecosystem Documentation

Welcome to the official documentation for the **`blaisevue-ecosystem`** repository!

This repository serves as the official community hub for packages, extensions, heavy graphics engines (such as Three.js, Plotly.js, Leaflet), and optional plugins for the [BlaiseVue](https://github.com/affonsoelias/BlaiseVue) framework.

---

## 🧭 Available Guides & Manuals

| Document | Description |
|---|---|
| 🚀 [**01. Getting Started & Usage**](01-getting-started.md) | How to search, install, update, and manage ecosystem packages with BlaiseVue CLI. |
| 🧩 [**02. Package Anatomy**](02-package-anatomy.md) | Standard directory structure, `package.json`, Pascal units, `.bv` SFC components, and `setup.pas`. |
| 🛠️ [**03. Creating a New Package**](03-creating-packages.md) | Step-by-step guide to scaffold libraries with `bv create --lib`, develop in an isolated sandbox, and run tests. |
| 📦 [**04. Packaging, Publishing & Examples**](04-packaging-and-publishing.md) | Packaging with `bv lib pack`, GitHub Releases with prefixed tags, `ecosystem.json`, and submitting demos to `examples/`. |
| 🌐 [**05. Custom Registries**](05-custom-registries.md) | Hosting private or corporate package registries compatible with BlaiseVue CLI. |

---

## 💡 Runnable Examples & Demos

Visit the [**`examples/`**](../examples/README.md) directory to explore real-world BlaiseVue projects demonstrating published packages in action. Authors can contribute demo projects directly under `examples/<package-name>/`.

---

## 🌟 Ecosystem Architecture & Principles

1. **Zero Core Bloat**: The primary BlaiseVue framework repository stays clean, lightweight, and fast to clone and compile.
2. **Strict SemVer Versioning**: Full support for historical versions and pinned tags (`<package>@<version>`) via GitHub Releases.
3. **Global Offline Cache**: Downloaded packages are cached in `~/.blaisevue/packages/`, enabling instant, offline installations across any project.
4. **Clean SDK Boundary & Seamless Self-Updates**: Downloaded libraries never pollute the BlaiseVue SDK working tree, guaranteeing that `bv self-update` operations never experience merge conflicts.
