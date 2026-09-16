# Build the broker binaries
FROM --platform=$BUILDPLATFORM golang:1.27 AS builder

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source
COPY bucketbroker/ bucketbroker/
COPY common/ common/
COPY machinebroker/ machinebroker/
COPY volumebroker/ volumebroker/

ARG TARGETOS
ARG TARGETARCH
ARG LDFLAGS

RUN mkdir bin

FROM builder AS machinebroker-builder

RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH GO111MODULE=on go build -ldflags="${LDFLAGS}" -a -o bin/machinebroker ./machinebroker/cmd/machinebroker/main.go

FROM builder AS volumebroker-builder

RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH GO111MODULE=on go build -ldflags="${LDFLAGS}" -a -o bin/volumebroker ./volumebroker/cmd/volumebroker/main.go

FROM builder AS bucketbroker-builder

RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH GO111MODULE=on go build -ldflags="${LDFLAGS}" -a -o bin/bucketbroker ./bucketbroker/cmd/bucketbroker/main.go

# TODO: Switch to distroless as soon as ephemeral debug containers are more broadly available.
FROM debian:bullseye-slim AS machinebroker
WORKDIR /
COPY --from=machinebroker-builder /workspace/bin/machinebroker .
USER 65532:65532

ENTRYPOINT ["/machinebroker"]

# TODO: Switch to distroless as soon as ephemeral debug containers are more broadly available.
FROM debian:bullseye-slim AS volumebroker
WORKDIR /
COPY --from=volumebroker-builder /workspace/bin/volumebroker .
USER 65532:65532

ENTRYPOINT ["/volumebroker"]

# TODO: Switch to distroless as soon as ephemeral debug containers are more broadly available.
FROM debian:bullseye-slim AS bucketbroker
WORKDIR /
COPY --from=bucketbroker-builder /workspace/bin/bucketbroker .
USER 65532:65532

ENTRYPOINT ["/bucketbroker"]
