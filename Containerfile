# Automatic Secret Rotation Container Image
# This container image provides the ASR CLI tool for automatic secret rotation

FROM alpine:3.19

# Install required dependencies
RUN apk add --no-cache \
    ca-certificates \
    curl \
    bash

# Set version - this will be overridden by build args
ARG ASR_VERSION=latest

# Download and install the ASR binary from the latest release
RUN set -eux; \
    ARCH="$(uname -m)"; \
    case "$ARCH" in \
        x86_64) BINARY_ARCH='x86_64-unknown-linux-musl' ;; \
        aarch64) BINARY_ARCH='aarch64-unknown-linux-musl' ;; \
        *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac; \
    \
    if [ "$ASR_VERSION" = "latest" ]; then \
        RELEASE_URL="https://api.github.com/repos/kelleyblackmore/Automatic-Secret-Rotation/releases/latest"; \
    else \
        RELEASE_URL="https://api.github.com/repos/kelleyblackmore/Automatic-Secret-Rotation/releases/tags/${ASR_VERSION}"; \
    fi; \
    \
    # For now, we'll build from source since binaries aren't available in releases yet
    # This is a temporary solution until the ASR repo starts publishing release binaries
    apk add --no-cache --virtual .build-deps \
        rust \
        cargo \
        git \
        musl-dev; \
    \
    cd /tmp; \
    if [ "$ASR_VERSION" = "latest" ]; then \
        git clone --depth 1 https://github.com/kelleyblackmore/Automatic-Secret-Rotation.git; \
    else \
        git clone --depth 1 --branch "${ASR_VERSION}" https://github.com/kelleyblackmore/Automatic-Secret-Rotation.git; \
    fi; \
    \
    cd Automatic-Secret-Rotation; \
    cargo build --release --locked; \
    \
    # Install the binary
    install -m 755 target/release/asr /usr/local/bin/asr; \
    \
    # Cleanup
    cd /; \
    rm -rf /tmp/Automatic-Secret-Rotation; \
    apk del .build-deps; \
    rm -rf /root/.cargo /root/.rustup

# Verify installation
RUN asr --version

# Set working directory
WORKDIR /workspace

# Set entrypoint to asr
ENTRYPOINT ["/usr/local/bin/asr"]

# Default command shows help
CMD ["--help"]
