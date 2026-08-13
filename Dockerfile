# sqlite-litestream — SQLite + Litestream replication sidecar (+ optional
# sqlite-web admin UI), riding the SQLite-in-production wave.
ARG LITESTREAM_VERSION=0.3.13

FROM alpine:3.24@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS fetch
ARG LITESTREAM_VERSION
ARG TARGETARCH=amd64
RUN apk add --no-cache ca-certificates=20260611-r0
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
RUN wget -qO- "https://github.com/benbjohnson/litestream/releases/download/v${LITESTREAM_VERSION}/litestream-v${LITESTREAM_VERSION}-linux-${TARGETARCH}.tar.gz" \
      | tar -xz -C / litestream

FROM python:3.14-alpine3.22@sha256:6b91e66ab2a880ce9ca5a1b91c70f45963ff71ff68268df056336e1a657d5efd
ARG LITESTREAM_VERSION
LABEL org.opencontainers.image.title="sqlite-litestream" \
      org.opencontainers.image.description="SQLite + Litestream replication sidecar with optional sqlite-web UI" \
      org.opencontainers.image.version="${LITESTREAM_VERSION}" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/fabiocicerchia/sqlite-litestream"
RUN apk add --no-cache sqlite=3.49.2-r1 tini=0.19.0-r3 \
 && pip install --no-cache-dir sqlite-web==0.6.4 \
 && adduser -D -u 10001 sqlite
COPY NOTICE /NOTICE
COPY --from=fetch /litestream /usr/local/bin/litestream
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
USER 10001
# ponytail: liveness of the litestream binary — mode-agnostic (replicate/restore/web).
# Upgrade to litestream's metrics HTTP addr if you enable it for real replica-lag checks.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD ["litestream", "version"]
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["replicate"]
