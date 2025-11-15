# Automatic Secret Rotation Container Image
# This container image uses the upstream install script to install the ASR CLI

FROM alpine:3.20

# Install runtime dependencies. We include git so that the installer can
# fall back to building from source if a pre-built binary is unavailable.
RUN apk add --no-cache \
    ca-certificates \
    curl \
    bash \
    git

# The ASR version to install. "latest" means install the most recent
# release. You can override this at build time with --build-arg ASR_VERSION=<tag>.
ARG ASR_VERSION=latest

# Download and run the install script from the main repository. The script will
# download the appropriate binary for the current architecture or build from
# source if no binary exists. The binary is installed into /usr/local/bin.
RUN set -eux; \
    # Fetch the installer from the main branch of Automatic-Secret-Rotation
    curl -fsSL https://raw.githubusercontent.com/kelleyblackmore/Automatic-Secret-Rotation/main/install.sh -o /tmp/install.sh; \
    chmod +x /tmp/install.sh; \
    # If a specific version is requested, export it for the installer. Without this
    # variable the installer will default to the latest release. A leading 'v' is
    # optional (e.g. ASR_VERSION=v0.3.0 or ASR_VERSION=0.3.0).
    if [ "$ASR_VERSION" != "latest" ]; then \
        export ASR_VERSION="$ASR_VERSION"; \
    fi; \
    # On unsupported architectures (e.g. arm64), force a source build by
    # exporting ASR_BUILD_FROM_SOURCE. The install script will then clone the
    # repository and build with cargo.
    case "$(uname -m)" in \
        aarch64|arm64) export ASR_BUILD_FROM_SOURCE=1 ;; \
    esac; \
    # Run the installer. The ASR binary will be placed in ~/.local/bin by default.
    ASR_BINARY_NAME=asr /tmp/install.sh; \
    # Move the binary into /usr/local/bin so it is on the PATH. We remove the
    # ~/.local directory afterwards to avoid leaving residual state.
    mv /root/.local/bin/asr /usr/local/bin/asr; \
    rm -rf /root/.local; \
    rm -f /tmp/install.sh

# Verify that the CLI works.
RUN asr --version

# Set a working directory for users of the image
WORKDIR /workspace

# Run the ASR CLI by default. A command like `docker run image init` will execute
# `asr init` inside the container.
ENTRYPOINT ["/usr/local/bin/asr"]

CMD ["--help"]
