# Claude Instructions for oci-images

## Project Overview

This repository builds and publishes OCI container images with automatic rolling releases.

## Goals (in priority order)

1. **Minimal image size**
   - Prefer `FROM scratch` with statically linked binaries when feasible
   - Always provide an Alpine-based `-debug` variant for debugging/shell access
   - Use multi-stage builds and strip binaries
   - Remove unnecessary files, docs, and dependencies from final images

2. **Always fresh**
   - Workflows check for new upstream releases every 6 hours
   - Build automatically when new versions are detected
   - Tag images with both `latest` and specific version numbers

3. **Rolling release ready**
   - Images designed for auto-updating deployments
   - Consistent tagging scheme across all images
   - No breaking changes within major versions

4. **Enhanced functionality**
   - Include useful addons/plugins where beneficial
   - Pre-configure sensible defaults
   - Add health checks to all images

## Repository Structure

```
images/<name>/
├── Dockerfile
├── README.md
├── .dockerignore
└── [additional files like entrypoint.sh]

.github/workflows/<name>.yml
```

## Workflow Requirements

- Pin all GitHub Actions to SHA hashes with version comments
- Use environment variables for workflow inputs (not direct `${{ }}` interpolation in shell)
- Validate version strings before building
- Check if image already exists before building
- Use GitHub Container Registry (ghcr.io)

## Dockerfile Best Practices

- Use `COPY --chmod=755` instead of separate `RUN chmod`
- Include `HEALTHCHECK` instruction
- Validate required environment variables in entrypoint scripts
- Add timeouts to all wait loops
- Use `set -eo pipefail` in shell scripts
- Handle errors explicitly with clear error messages

## Security

- Never interpolate untrusted input directly into shell/JavaScript strings
- Use `process.env` in JavaScript contexts to read environment variables
- Validate and sanitize all inputs
