# 💡 BlaiseVue Ecosystem Examples

This directory hosts runnable, real-world example applications demonstrating how to use packages published in the BlaiseVue Ecosystem.

---

## 📂 Directory Structure

Each subfolder corresponds to an ecosystem package or a combined multi-package showcase:

```text
examples/
├── README.md                  # This guide
├── <package-name>/            # Example project consuming <package-name>
│   ├── src/
│   │   ├── app.bv             # Root application component consuming the package
│   │   └── ...
│   ├── lib/                   # Installed libraries
│   ├── index.html             # HTML entry point
│   └── package.json           # Project manifest
└── ...
```

---

## 🚀 Running an Example

1. Navigate to the example folder:
   ```bash
   cd examples/<package-name>
   ```

2. Start the BlaiseVue live development server:
   ```bash
   bv dev
   ```

3. Open `http://localhost:8080` in your browser.

---

## 🤝 Submitting an Example

When submitting a new package to the ecosystem via Pull Request:
1. Create a dedicated folder `examples/<package-name>/`.
2. Include a clean, minimal BlaiseVue application demonstrating key features and component usage.
3. Reference your example in the root `README.md` package catalog table.
