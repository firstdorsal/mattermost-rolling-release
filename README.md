# OCI Images

A collection of container images built from source, automatically updated with new releases.

## Goals

1. **Minimal size** - Images as small as possible:
   - Prefer `FROM scratch` with statically linked binaries when feasible
   - Always provide an Alpine-based fallback (tagged `-debug`) for debugging and shell access
   - Use multi-stage builds and stripped binaries
2. **Always fresh** - Automatic builds when upstream releases new versions (checked every 6 hours)
3. **Rolling releases** - Images designed for auto-updating deployments with consistent tagging
4. **Enhanced functionality** - Useful features and addons included where beneficial (e.g., pre-configured plugins, optimized defaults)

## Available Images

| Image | Tag | Description | Workflow |
|-------|-----|-------------|----------|
| [mattermost](./images/mattermost/) | `ghcr.io/firstdorsal/mattermost-rolling-release-alpine` | Alpine-based Mattermost server | [![Mattermost](https://github.com/firstdorsal/oci-images/actions/workflows/mattermost.yml/badge.svg)](https://github.com/firstdorsal/oci-images/actions/workflows/mattermost.yml) |
| [mongodb](./images/mongodb/) | `ghcr.io/firstdorsal/mongodb-bitnami-compatible` | Bitnami-compatible MongoDB | [![MongoDB](https://github.com/firstdorsal/oci-images/actions/workflows/mongodb.yml/badge.svg)](https://github.com/firstdorsal/oci-images/actions/workflows/mongodb.yml) |

## Adding a New Image

1. Create a new directory under `images/` (e.g., `images/myapp/`)
2. Add a `Dockerfile` in the directory
3. Add a `README.md` with usage instructions
4. Create a workflow in `.github/workflows/<image-name>.yml`
5. Update this README to include the new image in the table

## License

This repository is licensed under the [GNU Affero General Public License v3.0](LICENSE).

Note: Individual images may include software with their own licensing terms. See the image directories for details.
