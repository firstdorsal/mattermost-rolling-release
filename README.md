# OCI Images

A collection of container images built from source, automatically updated with new releases.

## Available Images

| Image | Description | Workflow |
|-------|-------------|----------|
| [mattermost](./images/mattermost/) | Alpine-based Mattermost server | [![Mattermost](https://github.com/firstdorsal/oci-images/actions/workflows/mattermost.yml/badge.svg)](https://github.com/firstdorsal/oci-images/actions/workflows/mattermost.yml) |

## Adding a New Image

1. Create a new directory under `images/` (e.g., `images/myapp/`)
2. Add a `Dockerfile` in the directory
3. Add a `README.md` with usage instructions
4. Create a workflow in `.github/workflows/<image-name>.yml`
5. Update this README to include the new image in the table

## License

This repository is licensed under the [GNU Affero General Public License v3.0](LICENSE).

Note: Individual images may include software with their own licensing terms. See the image directories for details.
