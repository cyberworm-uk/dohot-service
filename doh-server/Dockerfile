FROM docker.io/library/rust:alpine AS build
ENV RUSTFLAGS="-C target-feature=-crt-static"
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
RUN apk add musl-dev pkgconfig openssl-dev sqlite-dev xz-dev --no-cache
RUN cargo install doh-proxy --no-default-features

FROM docker.io/library/alpine:latest
LABEL org.opencontainers.image.base.name="docker.io/library/alpine"
LABEL org.opencontainers.image.title="DOH Proxy"
LABEL org.opencontainers.image.description="DOH Proxy built for alpine as an optional front for DOHOT"
RUN apk add libgcc --no-cache && addgroup -S doh && adduser -S doh -G doh
COPY --from=build /usr/local/cargo/bin/doh-proxy /bin/doh-proxy
USER doh:doh
ENTRYPOINT [ "/bin/doh-proxy" ]
