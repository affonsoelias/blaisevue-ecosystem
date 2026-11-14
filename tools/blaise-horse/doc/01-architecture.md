# 01 - Architecture & Isolation

`blaise-horse` introduces modular backend versatility to BlaiseVue projects without introducing architectural debt or coupling.

## Architectural Principles

1. **Isolation by Design**:
   - BlaiseVue's enterprise mORMot 2 backend resides in `server/`.
   - The Horse microframework backend resides strictly in `server-horse/`.
   - Both backends can co-exist within the same repository during migrations or evaluation, with zero filename collisions or build conflicts.

2. **Upstream Direct Integration**:
   - `blaise-horse` acts as an orchestrator and project adapter ("casca").
   - When running `bv horse init`, it downloads the official [HashLoad/horse](https://github.com/HashLoad/horse) source directly into `server-horse/lib/horse/`.
   - Developers stay synchronized with upstream Horse improvements via `bv horse update`.

3. **Frontend-First Flexibility**:
   - A developer may choose to build a pure frontend SPA and omit any Pascal backend.
   - Alternatively, a developer can run `bv horse init` for a minimal, lightweight REST service, or run `bv mormot init` for full enterprise ORM/SOA capabilities.

4. **Lifecycle Symmetry**:
   - `bv horse init` / `bv horse remove [-y]`
   - `bv mormot init` / `bv mormot remove [-y]`
   - Both engines support complete, non-destructive removal if the user decides to change architectures.

---

## Directory Layout

```
project-root/
├── app.cfg                     # Project metadata and configuration
├── package.json                # Frontend dependencies
├── src/                        # Vue 3 + TypeScript application
│   ├── App.vue
│   └── main.ts
├── dist/                       # Output of `bv build` (or `npm run build`)
├── server/                     # mORMot 2 backend (default if enabled)
└── server-horse/               # Horse backend
    ├── .env                    # Port and runtime configuration
    ├── server.pas              # Main server executable source (Delphi mode)
    ├── server.lpi              # Lazarus IDE project file
    ├── Dockerfile              # Multi-stage micro-container build
    ├── lib/
    │   ├── horse/              # Official HashLoad Horse repository
    │   └── units/              # Compiled Free Pascal unit files (.ppu, .o)
    └── bin/
        └── server.exe          # Compiled native binary
```

---

## Runtime Model

The Horse backend starts as a standalone native process. When serving HTTP requests, it follows this resolution pipeline:

1. **CORS Headers**: Appended on all incoming requests to permit Vite dev-server hot reload requests (`http://localhost:5173`).
2. **Options Preflight**: Returns HTTP 204 immediately for preflight queries.
3. **API Routing**: Routes matching `/api/*` bypass static file handlers and execute corresponding Horse callbacks.
4. **Static File Resolution**: If an exact file exists inside `dist/`, it is streamed with correct MIME headers (`Res.SendFile`).
5. **SPA Fallback**: If the path does not match a file or an API endpoint, `dist/index.html` is returned, letting Vue Router handle frontend navigation.
