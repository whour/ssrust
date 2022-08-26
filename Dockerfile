#FROM --platform=$BUILDPLATFORM rust:1.61.0-alpine AS builder
FROM ghcr.io/shadowsocks/ssserver-rust:latest
ENV PASSWORD=
ENV METHOD=aes-256-gcm
FROM alpine:3.16 AS ssserver

COPY --from=builder /root/shadowsocks-rust/target/release/ssserver /usr/local/bin/
COPY --from=builder /root/shadowsocks-rust/docker/docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "sserver -s '0.0.0.0:8388' -k ${PASSWORD} -m ${METHOD}" ]
