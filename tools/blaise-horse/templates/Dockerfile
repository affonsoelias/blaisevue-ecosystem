# Multi-stage production container for BlaiseVue Horse Backend
# Stage 1: Build native Pascal binary with Free Pascal and HashLoad Horse
FROM alpine:3.19 AS builder
RUN apk add --no-cache fpc make binutils
WORKDIR /build
COPY . .
RUN fpc -MDelphi -Sh -O3 -Xs -CX -XX -Fulib/horse/src -Filib/horse/src server.pas -FEbin -obin/server

# Stage 2: Ultra-lightweight minimal runtime (< 20MB)
FROM alpine:3.19
RUN apk add --no-cache ca-certificates
WORKDIR /app
COPY --from=builder /build/bin/server /app/server
EXPOSE 9000
CMD ["/app/server", "9000"]
