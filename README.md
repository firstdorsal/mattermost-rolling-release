# OCI Images

A collection of container images built from source, automatically updated with new releases.

## Available Images

| Image | Description | Workflow |
|-------|-------------|----------|
| [mattermost](./mattermost/) | Alpine-based Mattermost server | [![Mattermost](https://github.com/firstdorsal/oci-images/actions/workflows/mattermost.yml/badge.svg)](https://github.com/firstdorsal/oci-images/actions/workflows/mattermost.yml) |

## Adding a New Image

1. Create a new directory for the image (e.g., `myapp/`)
2. Add a `Dockerfile` in the directory
3. Add a `README.md` with usage instructions
4. Create a workflow in `.github/workflows/<image-name>.yml`
5. Update this README to include the new image in the table

## License

Each image may have its own licensing terms. See the individual image directories for details.
