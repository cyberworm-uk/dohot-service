FROM docker.io/library/rust:alpine AS build
ENV RUSTFLAGS="-C target-feature=-crt-static"
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
RUN apk add musl-dev pkgconfig openssl-dev sqlite-dev xz-dev --no-cache
RUN cargo install doh-proxy --no-default-features

FROM ghcr.io/cyberworm-uk/base:latest
COPY --from=build /usr/local/cargo/bin/doh-proxy /bin/doh-proxy
RUN apk add libgcc --no-cache
RUN addgroup -S doh && adduser -S doh -G doh
USER doh:doh
ENTRYPOINT [ "/bin/doh-proxy" ]
