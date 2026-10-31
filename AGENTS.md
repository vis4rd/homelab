# Agent Instructions

This file is the canonical source of agent instructions for this repository. Follow the relevant sections when working on the matching files or tasks.

## Docker Compose Secret Environment Variables

Apply when creating or updating Docker Compose environment variables, secrets, credentials, `env_file` entries, or service `.env` files.

Keep secrets and credentials out of tracked Docker Compose files:

- Store secret or credential variables in the service-local `.env` file, such as `<stack>/<service>/.env`. Create the file if it does not exist.
- Reference that file from the service with an `env_file` entry.
- Do not place secret or credential variables under the Compose `environment` section.
- Add comments beside the `env_file` entry listing every required variable and what it is used for. Do not include secret values in those comments.

Keep non-secret and non-credential variables in the Compose `environment` section so they remain source-tracked and versioned with Git.

## Docker Compose Volume Mounts

Apply when writing or updating Docker Compose volume mounts, service configuration mounts, or container filesystem permissions, especially in `**/docker-compose.yml` files.

Prefer mounting service configuration directories instead of individual configuration files.

- Prefer: `./<service>/config:/path/in/container:ro`
- Avoid: `./<service>/config/file.yml:/path/in/container/file.yml`

Assume mounts should be read-only by default. Use a writable mount only when the service must persist or modify data in that directory, and make that requirement explicit in the Compose configuration or nearby documentation.

## Service Config Directory Layout

Apply when creating or relocating Docker service configuration directories, stack layouts, Compose mounts, or service config files.

Store each service's configuration under its service directory within the stack:

- Correct: `<stack>/<service>/config/`
- Incorrect: `<stack>/config/<service>/`

Keep configuration files and bind-mount paths consistent with this layout when adding or moving services.
