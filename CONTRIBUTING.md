# Contributing to ASR Container Image

Thank you for your interest in contributing to the Automatic Secret Rotation Container Image project!

## About This Repository

This repository builds container images for the [Automatic Secret Rotation (ASR)](https://github.com/kelleyblackmore/Automatic-Secret-Rotation) CLI tool. The images are published to GitHub Container Registry and can be used in containerized environments.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check if an issue already exists
2. If not, create a new issue with:
   - A clear title and description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Container image version and platform

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Test your changes locally:
   ```bash
   docker build -f Containerfile -t asr:test .
   docker run --rm asr:test --version
   ```
5. Commit your changes with clear messages
6. Push to your fork
7. Open a Pull Request

### Testing Changes

Before submitting a PR, please test:

1. **Build succeeds**: `docker build -f Containerfile .`
2. **Binary works**: `docker run --rm <image> --version`
3. **Basic commands**: `docker run --rm <image> --help`

### Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow

## Development Setup

### Prerequisites

- Docker or Podman
- Git

### Local Development

```bash
# Clone the repository
git clone https://github.com/kelleyblackmore/Automatic-Secret-Rotation-container-image.git
cd Automatic-Secret-Rotation-container-image

# Build the image
docker build -f Containerfile -t asr:dev .

# Test the image
docker run --rm asr:dev --version
docker run --rm asr:dev --help
```

### Building with Different ASR Versions

```bash
# Build with specific version
docker build -f Containerfile --build-arg ASR_VERSION=0.1.0 -t asr:0.1.0 .

# Build with latest
docker build -f Containerfile --build-arg ASR_VERSION=latest -t asr:latest .
```

## Release Process

The container images are automatically built and published via GitHub Actions when:

1. Code is pushed to the `main` branch
2. A new tag is created (e.g., `v1.0.0`)
3. A Pull Request is opened (for testing, not published)

## Questions?

If you have questions, please:

1. Check the [README](README.md)
2. Review the [ASR documentation](https://github.com/kelleyblackmore/Automatic-Secret-Rotation)
3. Open an issue for discussion

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (Apache License 2.0).
