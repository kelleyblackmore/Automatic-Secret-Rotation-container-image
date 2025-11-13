# Automatic Secret Rotation - Container Image

Container image for the [Automatic Secret Rotation (ASR)](https://github.com/kelleyblackmore/Automatic-Secret-Rotation) CLI tool.

This repository builds container images that include the ASR binary, making it easy to use in containerized environments, CI/CD pipelines, and Kubernetes deployments.

## Quick Start

### Pull the Image

```bash
docker pull ghcr.io/kelleyblackmore/automatic-secret-rotation-container-image:latest
```

### Basic Usage

```bash
# Show help
docker run --rm ghcr.io/kelleyblackmore/automatic-secret-rotation-container-image:latest --help

# Initialize config (will create in current directory via volume mount)
docker run --rm -v $(pwd):/workspace ghcr.io/kelleyblackmore/automatic-secret-rotation-container-image:latest init

# Scan for secrets needing rotation
docker run --rm \
  -e VAULT_ADDR="http://vault:8200" \
  -e VAULT_TOKEN="your-token" \
  ghcr.io/kelleyblackmore/automatic-secret-rotation-container-image:latest scan

# Auto-rotate secrets
docker run --rm \
  -e VAULT_ADDR="http://vault:8200" \
  -e VAULT_TOKEN="your-token" \
  ghcr.io/kelleyblackmore/automatic-secret-rotation-container-image:latest auto
```

## Usage with Configuration File

```bash
# Create a config file (rotator-config.toml) on your host
docker run --rm \
  -v $(pwd)/rotator-config.toml:/workspace/rotator-config.toml \
  ghcr.io/kelleyblackmore/automatic-secret-rotation-container-image:latest \
  -c /workspace/rotator-config.toml scan
```

## Kubernetes Deployment

### CronJob for Automatic Rotation

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: secret-rotation
spec:
  # Run weekly on Sunday at midnight
  schedule: "0 0 * * 0"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: asr
            image: ghcr.io/kelleyblackmore/automatic-secret-rotation-container-image:latest
            args: ["auto"]
            env:
            - name: VAULT_ADDR
              value: "http://vault:8200"
            - name: VAULT_TOKEN
              valueFrom:
                secretKeyRef:
                  name: vault-token
                  key: token
            - name: VAULT_MOUNT
              value: "secret"
          restartPolicy: OnFailure
```

### One-time Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: rotate-secrets
spec:
  template:
    spec:
      containers:
      - name: asr
        image: ghcr.io/kelleyblackmore/automatic-secret-rotation-container-image:latest
        args: ["auto", "--dry-run"]
        env:
        - name: VAULT_ADDR
          value: "http://vault:8200"
        - name: VAULT_TOKEN
          valueFrom:
            secretKeyRef:
              name: vault-token
              key: token
      restartPolicy: Never
```

## CI/CD Integration

### GitHub Actions

```yaml
- name: Rotate Secrets
  run: |
    docker run --rm \
      -e VAULT_ADDR="${{ secrets.VAULT_ADDR }}" \
      -e VAULT_TOKEN="${{ secrets.VAULT_TOKEN }}" \
      ghcr.io/kelleyblackmore/automatic-secret-rotation-container-image:latest auto
```

### GitLab CI

```yaml
rotate-secrets:
  image: ghcr.io/kelleyblackmore/automatic-secret-rotation-container-image:latest
  script:
    - asr auto
  variables:
    VAULT_ADDR: $VAULT_ADDR
    VAULT_TOKEN: $VAULT_TOKEN
```

## Available Tags

- `latest` - Latest build from main branch
- `main` - Latest build from main branch
- `v*.*.*` - Specific version tags
- `sha-*` - Specific commit SHA

## Building Locally

```bash
# Build the image
docker build -f Containerfile -t asr:local .

# Build with specific ASR version
docker build -f Containerfile --build-arg ASR_VERSION=0.1.0 -t asr:0.1.0 .

# Run locally built image
docker run --rm asr:local --version
```

## Supported Platforms

- linux/amd64
- linux/arm64

## Environment Variables

The container supports all ASR environment variables:

- `VAULT_ADDR` - Vault server address
- `VAULT_TOKEN` - Vault authentication token
- `VAULT_MOUNT` - Vault mount path (default: `secret`)
- `ROTATION_PERIOD_MONTHS` - Default rotation period in months
- `SECRET_LENGTH` - Length of generated secrets

## Links

- [ASR Source Repository](https://github.com/kelleyblackmore/Automatic-Secret-Rotation)
- [ASR Documentation](https://github.com/kelleyblackmore/Automatic-Secret-Rotation#readme)
- [Container Registry](https://github.com/kelleyblackmore/Automatic-Secret-Rotation-container-image/pkgs/container/automatic-secret-rotation-container-image)
