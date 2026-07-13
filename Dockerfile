# sqlite-litestream — SQLite + Litestream replication sidecar (+ optional
# sqlite-web admin UI), riding the SQLite-in-production wave.
ARG LITESTREAM_VERSION=0.3.13

FROM alpine:3.22 AS fetch
ARG LITESTREAM_VERSION
ARG TARGETARCH=amd64
RUN apk add --no-cache curl ca-certificates
RUN curl -fsSL "https://github.com/benbjohnson/litestream/releases/download/v${LITESTREAM_VERSION}/litestream-v${LITESTREAM_VERSION}-linux-${TARGETARCH}.tar.gz" \
      | tar -xz -C / litestream

FROM python:3.13-alpine3.22
ARG LITESTREAM_VERSION
LABEL org.opencontainers.image.title="sqlite-litestream" \
      org.opencontainers.image.description="SQLite + Litestream replication sidecar with optional sqlite-web UI" \
      org.opencontainers.image.version="${LITESTREAM_VERSION}" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/fabiocicerchia/freelancing"
RUN apk add --no-cache sqlite tini \
 && pip install --no-cache-dir sqlite-web==0.6.4 \
 && adduser -D -u 10001 sqlite
COPY --from=fetch /litestream /usr/local/bin/litestream
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
USER 10001
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["replicate"]
