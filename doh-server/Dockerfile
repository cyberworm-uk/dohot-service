FROM docker.io/library/rust:alpine AS build
ENV RUSTFLAGS="-C target-feature=-crt-static"
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
RUN apk add musl-dev pkgconfig openssl-dev sqlite-dev xz-dev --no-cache
RUN cargo install doh-proxy --no-default-features

FROM docker.io/library/alpine:latest
RUN apk add libgcc --no-cache && addgroup -S doh && adduser -S doh -G doh
COPY --from=build /usr/local/cargo/bin/doh-proxy /bin/doh-proxy
USER doh:doh
ENTRYPOINT [ "/bin/doh-proxy" ]
