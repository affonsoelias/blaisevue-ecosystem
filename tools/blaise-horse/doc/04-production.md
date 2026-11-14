# 04 - Production & Containerization

Deploying `blaise-horse` into production is streamlined thanks to Free Pascal's ahead-of-time compilation and single-binary output.

## Building for Production

To create an optimized binary with stripped symbols:

```bash
bv horse build --release
```

Free Pascal flags applied in release mode:
- `-O3`: Maximum code optimization level.
- `-Xs`: Strip debug symbols.
- `-CX`: Smart linking (removes unused code sections).
- `-XX`: Smart linking library references.

The resulting binary (`server-horse/bin/server` or `server.exe`) is typically under 4-6 MB with zero external runtime dependencies.

---

## Assembly with `bv horse deploy`

To package a standalone production release containing both the backend executable and the compiled frontend:

```bash
# 1. Build frontend
npm run build

# 2. Assemble release bundle
bv horse deploy
```

This creates `deploy/horse/`:
```
deploy/horse/
├── server.exe
└── dist/
    ├── index.html
    └── assets/
        ├── index.css
        └── index.js
```

Running `server.exe` inside `deploy/horse/` serves the frontend and handles the API out of the box.

---

## Docker Containerization

`server-horse/Dockerfile` provides a multi-stage Alpine build:

```dockerfile
# Stage 1: Build native Pascal binary
FROM alpine:3.19 AS builder
RUN apk add --no-cache fpc make musl-dev
WORKDIR /build
COPY . /build
RUN fpc -MObjFPC -Sh -O3 -Xs -CX -XX -FEbin server.pas

# Stage 2: Minimal runtime image
FROM alpine:3.19
WORKDIR /app
COPY --from=builder /build/bin/server /app/server
COPY ../dist /app/dist
EXPOSE 9000
CMD ["/app/server", "9000"]
```

Build and run with:

```bash
bv horse docker --build
docker run -p 9000:9000 blaise-horse-app
```
