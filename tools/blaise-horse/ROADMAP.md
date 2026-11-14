# Blaise-Horse Roadmap

This document outlines the development roadmap and planned capabilities for the `blaise-horse` developer tool within the BlaiseVue ecosystem.

---

## 🎯 Vision

The goal of `blaise-horse` is to provide a clean, lightweight, Express-like microframework backend for Pascal developers who value simplicity, zero external runtime dependencies, rapid prototyping, and effortless containerization alongside BlaiseVue's modern Vue 3 frontend.

While **mORMot 2** remains BlaiseVue's enterprise-grade, high-throughput default backend, `blaise-horse` offers an accessible and agile alternative for developers seeking minimalist architectures, microservices, or quick CRUD endpoints.

---

## 📌 Milestones

### Phase 1: Foundation (v1.0.0) — *Current Release*
- [x] Isolated directory structure in `server-horse/` (zero clashing with `server/`).
- [x] Direct upstream fetching of official **HashLoad Horse** microframework from GitHub into `server-horse/lib/horse/`.
- [x] Upstream synchronization command: `bv horse update`.
- [x] Official Express-like routing syntax (`THorse.Get`, `THorse.Post`, `THorse.Use`, `THorse.Listen`) in Free Pascal Delphi mode.
- [x] Pre-configured CORS middleware for local Vite/Vue development (`http://localhost:5173`).
- [x] Built-in static file server with Single Page Application (SPA) HTML5 history mode fallback (`dist/`).
- [x] Native CLI commands integrated into BlaiseVue (`bv horse init`, `update`, `build`, `run`, `status`, `kill`, `docker`, `deploy`, `remove`).
- [x] Safe uninstaller (`bv horse remove [-y]`) with zero impact on other project directories.
- [x] Lazarus IDE project file (`server.lpi`) for visual F9 debugging.
- [x] Alpine Linux multi-stage Dockerfile producing micro-containers (< 20MB).

---

### Phase 2: Swagger / OpenAPI Interactive Explorer (v1.1.0) — *Planned*
One of the most requested features for modern REST APIs is automated interactive documentation. In v1.1.0, `blaise-horse` will introduce integrated Swagger UI and OpenAPI 3.0 specification support:

- [ ] **OpenAPI 3.0 Spec Generation**:
  - Automatic JSON schema export at `/api/openapi.json`.
  - Pascal route metadata decorator/registration pattern (e.g., `RegisterRoute('GET', '/api/users', Handler, 'List all users', ['Tag:Users']);`).
- [ ] **Embedded Swagger UI**:
  - Embedded HTML/CSS/JS Swagger bundle served at `/api/docs` or `/swagger`.
  - Interactive "Try it out" console enabling live API testing directly against the running Pascal server.
  - Zero internet connection required (embedded statically into the binary or bundled in `server-horse/swagger/`).
- [ ] **CLI Documentation Exporter**:
  - `bv horse swagger export`: Generates an `openapi.json` or `openapi.yaml` file for CI/CD pipelines, Postman imports, and frontend TypeScript client generation (via `openapi-typescript` or `orval`).

---

### Phase 3: Database Connectivity & CRUD Generators (v1.2.0) — *Planned*
- [ ] **Native SQLite Support**:
  - Out-of-the-box template using Free Pascal's `sqlite3conn` and `sqldb`.
  - Zero client library configuration on Linux/macOS and automated DLL bundling on Windows.
- [ ] **ZeosLib / PostgreSQL Templates**:
  - Optional starter presets (`bv horse init --db sqlite` / `bv horse init --db postgres`).
- [ ] **CRUD Scaffolding CLI**:
  - `bv horse g:crud <entity>`: Automatically generates Pascal entity records, SQL table migration scripts, and REST handlers (GET, POST, PUT, DELETE) with standard JSON serialization.

---

### Phase 4: Production Hardening & Ecosystem Plugins (v2.0.0) — *Future Vision*
- [ ] **JWT Authentication Middleware**:
  - Built-in token signing, validation, and bearer authorization route guards.
- [ ] **Horse Official Ecosystem Compatibility**:
  - Optional adapter to seamlessly swap between native `fphttpserver` and the upstream community `horse` package via `boss` package manager when desired.
- [ ] **Health & Prometheus Metrics**:
  - Standard `/api/metrics` endpoint reporting memory usage, request counts, and execution latency.
