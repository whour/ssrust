#FROM --platform=$BUILDPLATFORM rust:1.61.0-alpine AS builder
FROM ghcr.io/shadowsocks/ssserver-rust:latest
ENV PASSWORD=
ENV METHOD=aes-256-gcm
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "sserver -s '0.0.0.0:8388' -k ${PASSWORD} -m ${METHOD}" ]
