# Bitnami-compatible MongoDB image
# Built on official MongoDB image with Bitnami directory structure and environment variables

ARG MONGODB_VERSION=8

FROM mongo:${MONGODB_VERSION}

COPY --chmod=755 entrypoint.sh /entrypoint.sh

# Create bitnami-compatible directory structure
RUN mkdir -p /bitnami/mongodb/data \
    && chown -R mongodb:mongodb /bitnami

VOLUME ["/bitnami/mongodb"]

EXPOSE 27017

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD mongosh --port 27017 --eval "db.adminCommand('ping')" || exit 1

ENTRYPOINT ["/entrypoint.sh"]
