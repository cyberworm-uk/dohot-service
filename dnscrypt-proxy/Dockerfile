FROM --platform=$BUILDPLATFORM docker.io/alpine/git:latest AS source
ARG VERSION=master
WORKDIR /go/src
RUN git clone --depth=1 -b ${VERSION} https://github.com/DNSCrypt/dnscrypt-proxy.git .

FROM --platform=$BUILDPLATFORM docker.io/library/golang:alpine AS build
ARG TARGETOS TARGETARCH
ENV GOOS="$TARGETOS" GOARCH="$TARGETARCH" GOFLAGS="-buildvcs=false -trimpath" CGO_ENABLED=0
COPY --from=source /go/src /go/src
WORKDIR /go/src/dnscrypt-proxy
RUN --mount=type=cache,target=/go/pkg go mod download
RUN --mount=type=cache,target=/go/pkg --mount=type=cache,target=/root/.cache/go-build go build -ldflags '-w -s -buildid=' .

FROM docker.io/library/alpine:latest
COPY --from=build /go/src/dnscrypt-proxy/dnscrypt-proxy /dnscrypt-proxy
RUN apk add --no-cache ca-certificates && mkdir -p /etc/dnscrypt-proxy/ /var/log/dnscrypt-proxy/
COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
RUN addgroup -S dnscrypt && adduser -S dnscrypt -G dnscrypt && chown dnscrypt:dnscrypt /etc/dnscrypt-proxy/ /var/log/dnscrypt-proxy/
USER dnscrypt
EXPOSE 5054/udp
EXPOSE 5054/tcp
VOLUME [ "/var/log/dnscrypt-proxy/" ]
VOLUME [ "/etc/dnscrypt-proxy/" ]
ENTRYPOINT [ "/dnscrypt-proxy", "-config", "/etc/dnscrypt-proxy/dnscrypt-proxy.toml" ]
