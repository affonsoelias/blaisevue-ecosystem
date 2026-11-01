# 🧩 02. BlaiseVue Package Anatomy

A BlaiseVue package is a modular, reusable distribution unit containing Single-File Components (`.bv`), Object Pascal units (`.pas`), CSS stylesheets, assets, scripts, and metadata.

---

## 📁 Recommended Directory Structure

A distributable package adheres to the following layout:

```text
my-package/
├── package.json         # Mandatory metadata and version manifest
├── README.md            # Component documentation and usage guide
├── LICENSE              # Software license (MIT, Apache-2.0, LGPL-3.0, etc.)
├── setup.pas            # (Optional) Pascal lifecycle script executed on install/remove
├── MyPackage.pas        # Primary Pascal unit (classes, types, helper routines)
├── BVMyButton.bv        # BlaiseVue Single-File Component (.bv)
├── styles/              # (Optional) Component stylesheets
│   └── my-package.css
└── tests/               # (Optional) Automated unit tests
    └── MyPackage.test.pas
```

---

## 📄 The `package.json` Manifest

The `package.json` at the root of the library identifies the package for the BlaiseVue CLI and the ecosystem catalog:

```json
{
  "name": "my-package",
  "version": "1.0.0",
  "description": "Reactive chart and dashboard components for BlaiseVue",
  "main": "MyPackage.pas",
  "author": "Your Name <your-email@example.com>",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/user/my-package"
  },
  "keywords": [
    "blaisevue",
    "charts",
    "ui",
    "components"
  ]
}
```

### Key Fields:
- **`name`**: Unique package identifier (lowercase letters and hyphens).
- **`version`**: Strict Semantic Versioning string (`MAJOR.MINOR.PATCH`).
- **`description`**: Summary displayed in search results (`bv lib search`).
- **`main`**: Entry-point Pascal unit exporting library classes and routines.
- **`license`**: SPDX license identifier (MIT, Apache-2.0, LGPL-3.0, etc.).

---

## ⚙️ Lifecycle Script `setup.pas` (Optional)

If your package needs to configure additional project assets during installation or perform cleanup during uninstallation, you can include an optional `setup.pas` script:

```pascal
program setup;
uses SysUtils;

var
  Action: string;
begin
  if ParamCount > 0 then
    Action := LowerCase(ParamStr(1))
  else
    Action := 'install';

  if Action = 'install' then
  begin
    WriteLn('  [Setup] Configuring assets for my-package...');
    // Perform custom initialization actions
  end
  else if Action = 'remove' then
  begin
    WriteLn('  [Setup] Cleaning up temporary assets for my-package...');
    // Perform uninstallation actions
  end;
end.
```

The BlaiseVue CLI automatically detects `setup.pas` and executes:
- `setup.pas install` upon package installation (`bv lib install`).
- `setup.pas remove` upon package removal (`bv lib remove`).

---

## 🎨 Automatic Asset Registration

When a package is installed in `lib/<package>/`:
1. **`.bv` Components**: The BlaiseVue compiler recursively scans `lib/` and registers all `.bv` Single-File Components globally without manual imports.
2. **`.css` Stylesheets**: CSS files inside `lib/` are detected and automatically injected into the generated `dist/index.html`.
3. **`.js` Vendor Scripts**: JavaScript vendor dependencies (e.g., Chart.js, Three.js) bundled inside `lib/` are copied to `dist/js/lib/` and linked in the HTML document.
