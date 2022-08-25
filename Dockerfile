FROM --platform=$BUILDPLATFORM rust:1.61.0-alpine AS builder

ENV SERVER_ADDR=0.0.0.0
ENV SERVER_PORT=8388
ENV PASSWORD=
ENV METHOD=aes-256-gcm
ENV TIMEOUT=300
ENV DNS_ADDRS="8.8.8.8,8.8.4.4"
ENV TZ=UTC
ENV ARGS=

ARG TARGETARCH

RUN set -x \
    && apk add --no-cache build-base

WORKDIR /root/shadowsocks-rust

ADD . .

RUN case "$TARGETARCH" in \
    "386") \
        RUST_TARGET="i686-unknown-linux-musl" \
        MUSL="i686-linux-musl" \
    ;; \
    "amd64") \
        RUST_TARGET="x86_64-unknown-linux-musl" \
        MUSL="x86_64-linux-musl" \
    ;; \
    *) \
        echo "Doesn't support $TARGETARCH architecture" \
        exit 1 \
    ;; \
    esac \
    && wget -qO- "https://musl.cc/$MUSL-cross.tgz" | tar -xzC /root/ \
    && PATH="/root/$MUSL-cross/bin:$PATH" \
    && CC=/root/$MUSL-cross/bin/$MUSL-gcc \
    && echo "CC=$CC" \
    && rustup override set nightly \
    && rustup target add "$RUST_TARGET" \
    && RUSTFLAGS="-C linker=$CC" CC=$CC cargo build --target "$RUST_TARGET" --release --features "local-tun local-redir armv8 neon stream-cipher aead-cipher-2022" \
    && mv target/$RUST_TARGET/release/ss* target/release/


FROM alpine:3.16 AS ssserver

COPY --from=builder /root/shadowsocks-rust/target/release/ssserver /usr/local/bin/
COPY --from=builder /root/shadowsocks-rust/docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "docker-entrypoint.sh" ]

CMD [ "ssserver"]
