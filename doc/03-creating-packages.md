# 🛠️ 03. Creating a New Package

BlaiseVue includes a dedicated scaffolding generator to create modular libraries and standalone components featuring an interactive development sandbox, automated unit testing, and integrated release packaging.

---

## 🏗️ 1. Scaffolding the Library

To scaffold a new library, run `bv create` with the `--lib` flag:

```bash
bv create my-widget --lib
```

### Interactive License Selection
The CLI prompts you to select a software license:
- **MIT** (Permissive default)
- **Apache-2.0**
- **LGPL-3.0** (Recommended for shared dynamic libraries)
- **GPL-3.0**
- **BSD-3-Clause**
- **Commercial**

> **CI/CD Tip**: Specify the license non-interactively using `--license <type>`:
> ```bash
> bv create my-widget --lib --license mit
> ```

---

## 📂 2. Generated Library Layout

```text
my-widget/
├── src/
│   ├── BVMyWidget.bv       # Initial Single-File Component
│   └── MyWidget.pas        # Pascal unit containing logic and types
├── styles/
│   └── my-widget.css       # Isolated component stylesheets
├── demo/
│   ├── index.html          # Browser sandbox playground
│   └── App.bv              # Interactive demonstration component
├── tests/
│   └── MyWidget.test.pas   # Automated unit test suite
├── package.json            # Package metadata and SemVer manifest
├── LICENSE                 # License text
└── README.md               # Library documentation
```

---

## 🧪 3. Developing in Sandbox with HMR

Navigate to the library directory and start the live development server:

```bash
cd my-widget
bv dev
```

The dev server launches at `http://localhost:8080` with Hot Module Replacement (HMR):
- Any modification made to `src/BVMyWidget.bv` or `styles/my-widget.css` is immediately reflected in the browser sandbox without a full page refresh.

---

## ✅ 4. Authoring and Running Tests

Write unit tests for your library inside `tests/`:

```pascal
unit MyWidget.test;
{$mode objfpc}{$H+}

interface
uses SysUtils, Classes;

type
  TTestMyWidget = class
  published
    procedure TestInitialization;
  end;

implementation

procedure TTestMyWidget.TestInitialization;
begin
  WriteLn('  [TEST] Validating initial component state...');
  // Assert expected behavior
end;

end.
```

To run all automated tests:
```bash
bv test
```

The CLI executes pre-flight tests automatically before release packaging to prevent distributing broken code.
