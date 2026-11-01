# 🚀 01. Getting Started & Ecosystem Usage

This guide explains how to consume, install, update, and manage packages from the `blaisevue-ecosystem` in your BlaiseVue projects using the native CLI (`bv`).

---

## 🔍 1. Searching for Packages

You can search by keyword or list all packages available in the catalog:

```bash
# Search for a specific keyword:
bv lib search chart

# List all packages available in the ecosystem:
bv lib search
```

**Terminal Output Example:**
```text
=== Package Search in BlaiseVue Ecosystem ===
Filter: "chart"
-----------------------------------------------------------------
  * blaise-charts (v1.0.0)
    Description: Reusable Chart.js reactive components for BlaiseVue
    Author:      BlaiseVue Core Team

1 package(s) found. To install, run: bv lib install <name>
-----------------------------------------------------------------
```

---

## 📥 2. Installing Packages (`bv lib install`)

The BlaiseVue package manager resolves packages using a 4-tier hierarchy:

### Local Project Installation (Default)
Installs the library into your project's `lib/<package>/` folder:

```bash
# Install the latest stable version:
bv lib install test

# Install a specific pinned version with @version:
bv lib install test@1.0.0
```

### User Global Cache Installation (`--global` / `-g`)
To download a package into your global offline cache for instant use across any future project:

```bash
bv lib install test --global
# or using the short alias:
bv lib install test -g
```

The package is stored in `~/.blaisevue/packages/test/`. When running `bv lib install test` in any subsequent project, the CLI copies the package from the local cache in milliseconds without requiring an internet connection.

---

## 📋 3. Listing Installed Packages (`bv lib list`)

```bash
# List libraries installed in current project (/lib):
bv lib list

# List packages cached in user global directory:
bv lib list --global
```

**Terminal Output Example (`bv lib list`):**
```text
=== Installed Libraries in Project (/lib) ===
-------------------------------------------------------
  - test (v1.1.0)
  - blaise-ui (v4.4.0) [Official Core]
  - themes (v4.4.0) [Official Core]
-------------------------------------------------------
Official Core Packages (packages/core):
  - blaise-themes, blaise-icons, blaise-ui, blaise-ui-mobile,
    blaise-charts, blaise-reports, blaise-studio
Use "bv lib list --global" to view packages in global cache.
-------------------------------------------------------
```

---

## 🔍 4. Checking for Updates (`bv lib outdated`)

To check whether installed libraries in your project or global cache have newer versions available:

```bash
# Check local project libraries:
bv lib outdated

# Check user global cache:
bv lib outdated --global
```

**Terminal Output Example:**
```text
=== Package Version Inspection (bv lib outdated) ===
Scope: Local Project (/lib)
------------------------------------------------------------------------------
Package               Installed     Latest          Status                    
------------------------------------------------------------------------------
test                  v1.0.0        v1.1.0          Outdated -> v1.1.0
blaise-ui             v4.4.0        v4.4.0          Official Core (Up to date)
------------------------------------------------------------------------------
1 of 2 package(s) are outdated.
To update, run: bv lib update
```

---

## 🔄 5. Upgrading Packages (`bv lib update`)

```bash
# Upgrade all out-of-date libraries in the project:
bv lib update

# Upgrade only a specific package:
bv lib update test

# Upgrade packages in user global cache:
bv lib update --global
```

---

## 🗑️ 6. Removing Packages (`bv lib remove`)

```bash
# Remove package from current project (/lib):
bv lib remove test

# Remove package from user global cache:
bv lib remove test --global
```

> **Safety Notice**: Official core framework packages (`packages/core/`) are protected against accidental deletion.
