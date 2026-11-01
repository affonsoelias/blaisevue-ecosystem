# 🌐 05. Creating Custom & Private Registries

BlaiseVue is architected to be completely decentralized. Enterprises and development teams can host their own private registries and internal package ecosystems without relying solely on the official public community repository.

---

## 🏗️ 1. What is a BlaiseVue Registry?

A BlaiseVue package registry is any HTTP/HTTPS server or Git repository (public or private) that serves a valid `ecosystem.json` manifest.

Minimal `ecosystem.json` example:
```json
{
  "name": "acme-corp-packages",
  "description": "Internal package and component registry for ACME Corp",
  "version": "1.0.0",
  "packages": {
    "acme-ui-auth": {
      "name": "acme-ui-auth",
      "description": "Enterprise SSO and MFA authentication component",
      "latest": "2.4.0",
      "versions": ["2.3.0", "2.4.0"],
      "download": "https://github.com/acme-corp/acme-packages/releases/download/{tag}/{package}-{version}.zip"
    }
  }
}
```

---

## 🔗 2. Registering Repositories in the CLI (`bv repo add`)

Each developer on your team can configure the private repository using `bv repo add`:

```bash
bv repo add acme https://github.com/acme-corp/acme-packages
```

### Supported URL Schemas:
- GitHub Repositories: `https://github.com/organization/repository`
- Internal Web Servers: `https://nexus.intranet.corp/blaisevue/ecosystem.json`

---

## 🎯 3. Configuring the Default Repository (`bv repo default`)

To prioritize package resolution from your enterprise registry before querying the public community catalog:

```bash
bv repo default acme
```

To inspect active repositories:
```bash
bv repo list
```

**Terminal Output Example:**
```text
=== BlaiseVue Package Repositories ===
Config: C:\Users\Pichau\.blaisevue\repos.json

  * acme (default)
      URL:  https://github.com/acme-corp/acme-packages
      Type: ecosystem

    official
      URL:  https://github.com/affonsoelias/blaisevue-ecosystem
      Type: ecosystem

Total: 2 configured repository(ies).
```

---

## 🔄 4. Synchronizing & Searching Packages

To synchronize the local metadata cache with all registered sources:

```bash
bv repo sync
```

The CLI downloads the `ecosystem.json` from each repository into `~/.blaisevue/cache/<name>-ecosystem.json`.

Now, search and install commands seamlessly query both public and private packages:
```bash
bv lib search acme
bv lib install acme-ui-auth
```

---

## 🔀 5. Multi-Registry Disambiguation (`<repo>:<package>`)

When working with multiple registered package repositories (e.g. `official` and `acme`), BlaiseVue provides deterministic resolution and collision safety:

1. **Default Repository Priority**: If no repository prefix is provided (e.g. `bv lib install my-pkg`), BlaiseVue queries the active default repository first (`"default": true`).
2. **Duplicate Notification**: If a package with the same name exists across multiple registries, the CLI resolves from the default source and alerts the developer:
   ```text
   Notice: Package "test" was also found in repository: acme.
           Using [official] (by priority). To specify repository, use: bv lib install <repo>:test
   ```
3. **Explicit Targeting**: You can explicitly specify the target repository using `<repo>:<package>[@version]`:
   ```bash
   bv lib install acme:test@1.1.0
   bv lib install official:test
   bv lib update acme:my-pkg
   bv lib search acme:
   ```
4. **Core Reserved Names Shielding**: Private and third-party repositories are prohibited from publishing packages with reserved core names (e.g. `acme:ui` or `acme:blaise-charts`). The CLI will reject installation with a security exception to ensure core framework stability.
