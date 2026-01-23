# Mattermost Rolling Release

Alpine-based Mattermost Docker image built from source, automatically updated with new releases.

## Usage

```bash
docker pull ghcr.io/firstdorsal/mattermost-rolling-release-alpine:latest
```

Or use a specific version:

```bash
docker pull ghcr.io/firstdorsal/mattermost-rolling-release-alpine:11.3.0
```

## Docker Compose Example

```yaml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: mattermost
      POSTGRES_PASSWORD: mattermost
      POSTGRES_DB: mattermost
    volumes:
      - postgres-data:/var/lib/postgresql/data

  mattermost:
    image: ghcr.io/firstdorsal/mattermost-rolling-release-alpine:latest
    depends_on:
      - postgres
    environment:
      MM_SQLSETTINGS_DRIVERNAME: postgres
      MM_SQLSETTINGS_DATASOURCE: postgres://mattermost:mattermost@postgres:5432/mattermost?sslmode=disable
      MM_SERVICESETTINGS_SITEURL: https://mattermost.example.com
    volumes:
      - mattermost-config:/mattermost/config
      - mattermost-data:/mattermost/data
      - mattermost-logs:/mattermost/logs
      - mattermost-plugins:/mattermost/plugins
      - mattermost-client-plugins:/mattermost/client/plugins
    ports:
      - "8065:8065"

volumes:
  postgres-data:
  mattermost-config:
  mattermost-data:
  mattermost-logs:
  mattermost-plugins:
  mattermost-client-plugins:
```

## Features

- Built from source (Team Edition)
- Alpine-based for minimal image size (~336MB)
- Binaries stripped for smaller size
- Automatic builds when new Mattermost versions are released
- Multi-version tags available

## Volume Mounts

Mount only the data directories, not the entire `/mattermost` folder:

| Path | Purpose |
|------|---------|
| `/mattermost/config` | Configuration files |
| `/mattermost/data` | User uploads and data |
| `/mattermost/logs` | Log files |
| `/mattermost/plugins` | Server plugins |
| `/mattermost/client/plugins` | Client plugins |

## Environment Variables

See the [Mattermost documentation](https://docs.mattermost.com/configure/configuration-settings.html) for all available environment variables. Common ones:

- `MM_SQLSETTINGS_DRIVERNAME` - Database driver (`postgres` or `mysql`)
- `MM_SQLSETTINGS_DATASOURCE` - Database connection string
- `MM_SERVICESETTINGS_SITEURL` - Public URL of your Mattermost instance

## License

Mattermost source code is licensed under the Mattermost Source Available License. See [Mattermost licensing](https://mattermost.com/licensing/) for details.
