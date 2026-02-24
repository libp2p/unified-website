# Ephemeral Self-Hosted GitHub Actions Runner

This directory contains everything needed to build and run an ephemeral
self-hosted GitHub Actions runner in a Docker container. The runner registers
itself with a GitHub repository, executes a single job, and then
automatically de-registers -- hence "ephemeral." Docker Compose is configured
with `restart: unless-stopped`, so a fresh runner instance is created
automatically after each job completes.

## Overview

| File                  | Purpose                                                |
|-----------------------|--------------------------------------------------------|
| `Dockerfile`          | Builds a Debian 13 image with the GitHub Actions runner, Zola, AWS CLI, GitHub CLI, Node.js, and other tools |
| `entrypoint.sh`       | Obtains a short-lived registration token, configures the runner, and starts it in ephemeral mode |
| `env`                 | Template for required environment variables             |
| `docker-compose.yaml` | Defines the runner service                                |

## Prerequisites

- A Linux host with Docker and Docker Compose installed
- Network access to GitHub (api.github.com and github.com)
- A GitHub Personal Access Token (see below)

## 1. Create a GitHub Personal Access Token

The runner needs a Personal Access Token (PAT) to request short-lived
registration tokens from the GitHub API at startup.

### Using a Fine-Grained Token (recommended)

1. Go to **Settings > Developer settings > Personal access tokens > Fine-grained tokens** on GitHub.
2. Click **Generate new token**.
3. Set a descriptive name (e.g., `self-hosted-runner`).
4. Under **Repository access**, select **Only select repositories** and choose the target repository (e.g., `libp2p/unified-website`).
5. Under **Permissions > Repository permissions**, grant:
   - **Administration** -- Read and write (required to register runners)
6. Click **Generate token** and copy the value immediately.

### Using a Classic Token

1. Go to **Settings > Developer settings > Personal access tokens > Tokens (classic)**.
2. Click **Generate new token**.
3. Select the `repo` scope (full control of private repositories).
4. For organization runners, also select `admin:org`.
5. Click **Generate token** and copy the value.

## 2. Configure Environment Variables

Copy the template `env` file to `.env`:

```bash
cp env .env
```

Edit `.env` and fill in the values:

```dotenv
RUNNER_NAME=<runner name>
ACCESS_TOKEN=<access token>
```

| Variable       | Description |
|----------------|-------------|
| `RUNNER_NAME`  | A human-readable prefix for the runner. It is appended with the service name in docker-compose (e.g., `myhost-unified-website`). |
| `ACCESS_TOKEN` | The GitHub Personal Access Token created in step 1. |

The `.env` file is read automatically by Docker Compose and is used to
interpolate `${RUNNER_NAME}` and `${ACCESS_TOKEN}` in `docker-compose.yaml`.
Keep this file private -- do not commit it to version control.

## 3. Update docker-compose.yaml

Before first use, edit `docker-compose.yaml` and replace the placeholder image
reference with your actual GHCR username or organization:

```yaml
image: ghcr.io/<username>/libp2p-gh-runner:latest
```

If you need to point the runner at a different repository, update the
`REPO_URL` environment variable in the service definition as well.

## 4. Build the Docker Image

Build the runner image from the Dockerfile:

```bash
docker build -t ghcr.io/<username>/libp2p-gh-runner:latest .
```

To use a specific runner version, pass it as a build argument:

```bash
docker build \
  --build-arg RUNNER_VERSION=2.330.0 \
  -t ghcr.io/<username>/libp2p-gh-runner:latest .
```

Replace `<username>` with your GitHub username or organization name throughout.

## 5. Push the Image to GHCR

Authenticate with the GitHub Container Registry, then push:

```bash
# Log in (use your GitHub username and a PAT with write:packages scope)
echo "$GITHUB_TOKEN" | docker login ghcr.io -u <username> --password-stdin

# Push the image
docker push ghcr.io/<username>/libp2p-gh-runner:latest
```

The PAT used for GHCR authentication needs the `write:packages` scope (classic
token) or the **Packages -- Read and write** permission (fine-grained token).
This can be the same token as `ACCESS_TOKEN` if you add the required scope, or
a separate token.

## 6. Start the Runner

With the `.env` file in place and the image available, start the runner:

```bash
docker compose up -d
```

Docker Compose will:

1. Pull the image from `ghcr.io` (if not already local).
2. Start the container with the environment variables from `.env`.
3. The entrypoint script exchanges `ACCESS_TOKEN` for a short-lived
   registration token via the GitHub API.
4. The runner registers itself with the repository in ephemeral mode.
5. It picks up a single job, executes it, then exits.
6. Because `restart: unless-stopped` is set, Docker automatically restarts the
   container, which registers a fresh ephemeral runner for the next job.

### Useful Commands

```bash
# View logs
docker compose logs -f

# Stop the runner
docker compose down

# Rebuild and restart after Dockerfile changes
docker compose up -d --build

# Pull a newer image and restart
docker compose pull && docker compose up -d
```

## How It Works

The `entrypoint.sh` script runs each time the container starts:

1. **Validates** that `REPO_URL` (or `ORG_NAME` + `RUNNER_SCOPE=org`) and
   `ACCESS_TOKEN` are set.
2. **Requests a registration token** from the GitHub API using the PAT.
3. **Configures the runner** with `--ephemeral`, `--unattended`, and
   `--replace` flags so it handles exactly one job and then exits cleanly.
4. **Starts the runner** with `exec ./run.sh`, which takes over the container
   process.

Because the runner is ephemeral, each job gets a completely clean environment
with no leftover state from previous runs.

## Adding More Runners

To run against multiple repositories, duplicate the service block in
`docker-compose.yaml` with a different service name, container name, `REPO_URL`,
and `RUNNER_NAME`. All services share the same `.env` for the access token.

## Security Notes

- The `.env` file contains secrets. Ensure it is listed in `.gitignore`.
- The `ACCESS_TOKEN` PAT should have the minimum scopes necessary.
