# Automatic Secret Rotation Container Image
# This container image provides the ASR CLI tool for automatic secret rotation

FROM alpine:3.20

# Install required dependencies
RUN apk add --no-cache \
    ca-certificates \
    curl \
    bash

# Set version - this will be overridden by build args
ARG ASR_VERSION=latest

# Download and install the ASR binary
RUN set -eux; \
    ARCH="$(uname -m)"; \
    case "$ARCH" in \
        x86_64) \
            BINARY_NAME="asr-linux-x86_64" \
            ;; \
        aarch64|arm64) \
            BINARY_NAME="asr-linux-arm64" \
            ;; \
        *) \
            echo "Unsupported architecture: $ARCH" && exit 1 \
            ;; \
    esac; \
    \
    # Get latest release tag or use specified version
    if [ "$ASR_VERSION" = "latest" ]; then \
        RELEASE_TAG=$(curl -s "https://api.github.com/repos/kelleyblackmore/Automatic-Secret-Rotation/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' || echo ""); \
    else \
        RELEASE_TAG="$ASR_VERSION"; \
    fi; \
    \
    if [ -z "$RELEASE_TAG" ]; then \
        echo "No releases found, building from source..."; \
        BUILD_FROM_SOURCE=1; \
    else \
        echo "Found release: $RELEASE_TAG"; \
        DOWNLOAD_URL="https://github.com/kelleyblackmore/Automatic-Secret-Rotation/releases/download/${RELEASE_TAG}/${BINARY_NAME}"; \
        echo "Downloading ${BINARY_NAME} from ${DOWNLOAD_URL}..."; \
        if curl -fsSL -o /tmp/asr "$DOWNLOAD_URL"; then \
            chmod +x /tmp/asr; \
            mv /tmp/asr /usr/local/bin/asr; \
            echo "Downloaded pre-built binary successfully!"; \
            BUILD_FROM_SOURCE=0; \
        else \
            echo "Pre-built binary not available, building from source..."; \
            BUILD_FROM_SOURCE=1; \
        fi; \
    fi; \
    \
    # Build from source if binary download failed
    if [ "$BUILD_FROM_SOURCE" = "1" ]; then \
        echo "Installing build dependencies..."; \
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
        rm -rf /root/.cargo /root/.rustup; \
        echo "Built and installed from source!"; \
    fi

# Verify installation
RUN asr --version

# Set working directory
WORKDIR /workspace

# Set entrypoint to asr
ENTRYPOINT ["/usr/local/bin/asr"]

# Default command shows help
CMD ["--help"]

