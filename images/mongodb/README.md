# MongoDB Bitnami-Compatible

A Bitnami-compatible MongoDB Docker image built on the official MongoDB image, automatically updated with new releases.

## Usage

```bash
docker pull ghcr.io/firstdorsal/mongodb-bitnami-compatible:latest
```

Or use a specific version:

```bash
docker pull ghcr.io/firstdorsal/mongodb-bitnami-compatible:8.0.9
```

## Docker Compose Example

```yaml
services:
  mongodb:
    image: ghcr.io/firstdorsal/mongodb-bitnami-compatible:latest
    environment:
      MONGODB_ROOT_USER: root
      MONGODB_ROOT_PASSWORD: secretpassword
      MONGODB_REPLICA_SET_NAME: replicaset
      MONGODB_REPLICA_SET_KEY: replicasetkey
      MONGODB_ADVERTISED_HOSTNAME: mongodb
    volumes:
      - mongodb-data:/bitnami/mongodb
    ports:
      - "27017:27017"

volumes:
  mongodb-data:
```

## Features

- Built on official MongoDB image
- Bitnami-compatible directory structure and environment variables
- Automatic replica set initialization (single-member for transaction support)
- Automatic root user creation
- Automatic builds when new MongoDB versions are released

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MONGODB_ROOT_USER` | `root` | Admin username |
| `MONGODB_ROOT_PASSWORD` | (required) | Admin password |
| `MONGODB_PORT_NUMBER` | `27017` | Port to bind |
| `MONGODB_ADVERTISED_HOSTNAME` | `localhost` | Hostname in replica set config |
| `MONGODB_ADVERTISED_PORT_NUMBER` | Same as port | Port in replica set config |
| `MONGODB_REPLICA_SET_NAME` | `replicaset` | Replica set name |
| `MONGODB_REPLICA_SET_KEY` | `defaultkey` | Inter-node authentication key |

## Volume Mounts

| Path | Purpose |
|------|---------|
| `/bitnami/mongodb` | Data directory (actual data in `/bitnami/mongodb/data/db`) |

## Important Notes

- **Initialization is one-time only**: The root user is created on first startup. Changing `MONGODB_ROOT_USER` or `MONGODB_ROOT_PASSWORD` after initial setup will not update existing credentials. To reset, delete the volume and restart.
- **MONGODB_ROOT_PASSWORD is required**: The container will fail to start if this variable is not set.

## Why This Image?

This image provides a drop-in replacement for Bitnami MongoDB while using the official MongoDB base image. It's useful when you need:

- Bitnami-compatible environment variables
- Bitnami directory structure (`/bitnami/mongodb/...`)
- Official MongoDB image as base
- Automatic replica set setup for transaction support

## License

MongoDB is licensed under the Server Side Public License (SSPL). See [MongoDB licensing](https://www.mongodb.com/licensing/server-side-public-license) for details.
