# Multi-stage production container for BlaiseVue Horse Backend
# Stage 1: Build native Pascal binary with Free Pascal
FROM alpine:3.19 AS builder
RUN apk add --no-cache fpc make binutils
WORKDIR /build
COPY . .
RUN fpc -O3 -Xs -CX -XX server.pas -FEbin -obin/server

# Stage 2: Ultra-lightweight minimal runtime (< 20MB)
FROM alpine:3.19
RUN apk add --no-cache ca-certificates
WORKDIR /app
COPY --from=builder /build/bin/server /app/server
EXPOSE 9000
CMD ["/app/server", "9000"]
