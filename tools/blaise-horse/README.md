# blaise-horse: Horse Backend Tool for BlaiseVue

`blaise-horse` is a co-official developer tool for the [BlaiseVue](https://github.com/affonsoelias/BlaiseVue) ecosystem. It provides first-class support for scaffolding, building, running, and deploying lightweight REST API backends using the **Horse microframework** (inspired by Express.js) and Free Pascal's native networking stack.

## Highlights

- **Complete Isolation**: Lives exclusively in `server-horse/` and never conflicts with the default `server/` (mORMot 2).
- **Zero-Dependency Native Server**: Built on Free Pascal's standard `fcl-web` / `fphttpserver` stack, with zero mandatory external dynamic libraries. Compiles into an ultra-fast, single self-contained native executable.
- **Full SPA Integration**: Pre-configured to serve the compiled BlaiseVue frontend (`../dist/`) with SPA fallback routing, CORS support, and JSON API routing out of the box.
- **Symmetric CLI**: Control everything via `bv horse <command>` or `bv tool run blaise-horse <command>`.
- **Clean Removal**: Supports `bv horse remove [-y]` to safely purge `server-horse/` without touching the frontend or other parts of your project.
- **Lazarus & FPC Ready**: Includes `server.lpi` project files for visual F9 debugging in Lazarus IDE alongside command-line building with `fpc`.

---

## Installation

Install `blaise-horse` using the BlaiseVue CLI:

```bash
bv tool install blaise-horse
```

Verify installation:

```bash
bv tool list
```

---

## Quick Start

### 1. Initialize the Horse backend
Inside any BlaiseVue project root, run:

```bash
bv horse init
```

This creates the isolated `server-horse/` directory with:
- `server.pas`: Native Pascal REST server with CORS, JSON parsing, static SPA hosting, and sample endpoints.
- `server.lpi`: Lazarus project configuration file for IDE debugging.
- `Dockerfile`: Multi-stage Alpine container definition for microservice deployment (< 20MB).
- `.env`: Environment settings (default `PORT=9000`).

### 2. Run the server
Compile and start the server in development mode:

```bash
bv horse run
```

Or run in release mode on a custom port:

```bash
bv horse run --release --port 8080
```

### 3. Check health
Query the running Horse server:

```bash
bv horse status
```

### 4. Build standalone binaries
Compile `server-horse/server.pas` to `server-horse/bin/server.exe`:

```bash
bv horse build
bv horse build --release
```

### 5. Production deployment bundle
Assemble a ready-to-deploy bundle containing the release binary and the built frontend in `deploy/horse/`:

```bash
bv horse deploy
```

### 6. Remove Horse backend
If you decide to switch backends or keep only the frontend:

```bash
bv horse remove -y
```

---

## Command Reference

| Command | Description |
| :--- | :--- |
| `bv horse init` | Scaffolds the Horse backend into `server-horse/`. |
| `bv horse run [--release] [--port p]` | Compiles and starts the Horse server (default: port 9000). |
| `bv horse build [--release]` | Compiles `server-horse/server.pas` with Free Pascal (`fpc`). |
| `bv horse status [--port p]` | Checks the health endpoint of the running server (`/api/health`). |
| `bv horse kill [--port p]` | Terminates any active process listening on the backend port. |
| `bv horse docker [--build]` | Prepares or builds an Alpine Linux Docker container for Horse. |
| `bv horse deploy [--zip]` | Prepares a standalone distribution bundle in `deploy/horse/`. |
| `bv horse remove [-y]` | Safely deletes the `server-horse/` directory and deploy artifacts. |

---

## Directory Structure

When initialized, `blaise-horse` creates an isolated directory structure:

```
my-project/
├── app.cfg
├── package.json
├── src/                    # BlaiseVue Frontend (Vue 3 + TypeScript)
├── dist/                   # Built frontend assets
├── server/                 # mORMot 2 backend (default, if enabled)
└── server-horse/           # Horse backend (isolated)
    ├── .env                # Port and environment variables
    ├── server.pas          # Entry point and route registrations
    ├── server.lpi          # Lazarus IDE project file
    ├── Dockerfile          # Lightweight containerization
    └── bin/
        └── server.exe      # Compiled native executable
```

---

## Documentation

Comprehensive guides are located in the [`doc/`](./doc/) directory:
- [01 - Architecture & Isolation](./doc/01-architecture.md)
- [02 - Routing & API Endpoints](./doc/02-routing.md)
- [03 - Middlewares & CORS](./doc/03-middlewares.md)
- [04 - Production & Containerization](./doc/04-production.md)

Explore code patterns in the [`examples/`](./examples/) directory:
- [Basic REST API](./examples/basic-api/)
- [SQLite CRUD Backend](./examples/sqlite-crud/)
- [Custom Middleware](./examples/custom-middleware/)

For upcoming features, including automatic Swagger/OpenAPI documentation generation, check [ROADMAP.md](./ROADMAP.md).

---

## License

MIT © BlaiseVue Core Team
