# Alpine-based Mattermost Server - Built from source
# Multi-stage build from official Mattermost repository

ARG GO_VERSION=1.24
ARG NODE_VERSION=20

# =============================================================================
# Stage 1: Build the server
# =============================================================================
FROM golang:${GO_VERSION}-alpine AS server-builder

RUN apk add --no-cache \
    git \
    make \
    bash \
    curl \
    gcc \
    musl-dev \
    libffi-dev \
    binutils \
    && rm -rf /var/cache/apk/*

ARG MATTERMOST_VERSION=master
ARG BUILD_ID=ghcr.io/firstdorsal/mattermost-rolling-release

WORKDIR /src

RUN git clone --depth 1 --branch "${MATTERMOST_VERSION}" \
    https://github.com/mattermost/mattermost.git .

WORKDIR /src/server

RUN make setup-go-work
RUN make build-linux BUILD_NUMBER="${BUILD_ID}"
RUN strip /src/server/bin/mattermost /src/server/bin/mmctl

# =============================================================================
# Stage 2: Build the webapp
# =============================================================================
FROM node:${NODE_VERSION}-alpine AS webapp-builder

RUN apk add --no-cache \
    git \
    make \
    bash \
    python3 \
    autoconf \
    automake \
    libtool \
    nasm \
    gcc \
    g++ \
    musl-dev \
    pkgconfig \
    cairo-dev \
    pango-dev \
    jpeg-dev \
    giflib-dev \
    librsvg-dev \
    pixman-dev \
    && rm -rf /var/cache/apk/*

ARG MATTERMOST_VERSION=master

WORKDIR /src

RUN git clone --depth 1 --branch "${MATTERMOST_VERSION}" \
    https://github.com/mattermost/mattermost.git .

WORKDIR /src/webapp

RUN npm ci
RUN npm run build

# =============================================================================
# Stage 3: Final Alpine image
# =============================================================================
FROM alpine:3.21

ARG PUID=2000
ARG PGID=2000

ENV PATH="/mattermost/bin:${PATH}" \
    MM_INSTALL_TYPE="docker"

RUN apk add --no-cache \
    ca-certificates \
    curl \
    libc6-compat \
    libffi \
    mailcap \
    tzdata \
    poppler-utils \
    && rm -rf /var/cache/apk/*

RUN addgroup -g ${PGID} mattermost \
    && adduser -D -u ${PUID} -G mattermost -h /mattermost mattermost

RUN mkdir -p /mattermost/bin /mattermost/data /mattermost/logs \
    /mattermost/config /mattermost/plugins /mattermost/client/plugins \
    /mattermost/client \
    && chown -R mattermost:mattermost /mattermost

# Copy server binary
COPY --from=server-builder --chown=mattermost:mattermost \
    /src/server/bin/mattermost /mattermost/bin/mattermost
COPY --from=server-builder --chown=mattermost:mattermost \
    /src/server/bin/mmctl /mattermost/bin/mmctl

# Copy i18n files
COPY --from=server-builder --chown=mattermost:mattermost \
    /src/server/i18n /mattermost/i18n

# Copy templates
COPY --from=server-builder --chown=mattermost:mattermost \
    /src/server/templates /mattermost/templates

# Copy fonts
COPY --from=server-builder --chown=mattermost:mattermost \
    /src/server/fonts /mattermost/fonts

# Copy webapp
COPY --from=webapp-builder --chown=mattermost:mattermost \
    /src/webapp/channels/dist /mattermost/client

USER mattermost

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD curl -f http://localhost:8065/api/v4/system/ping || exit 1

EXPOSE 8065 8067 8074 8075

VOLUME ["/mattermost/data", "/mattermost/logs", "/mattermost/config", "/mattermost/plugins", "/mattermost/client/plugins"]

WORKDIR /mattermost

ENTRYPOINT ["/mattermost/bin/mattermost"]
