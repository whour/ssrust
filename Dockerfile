#FROM --platform=$BUILDPLATFORM rust:1.61.0-alpine AS builder
FROM ghcr.io/shadowsocks/ssserver-rust:latest
ENV SERVER_ADDR=::
ENV SERVER_PORT=8388
ENV PASSWORD=
ENV METHOD=aes-256-gcm



ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8388

STOPSIGNAL SIGINT

CMD [ "sserver -s ${SERVER_ADDR} -p ${SERVER_PORT} -k ${PASSWORD} -m ${METHOD}" ]
