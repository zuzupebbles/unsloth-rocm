# ROCm-enabled PyTorch base image from AMD
# Pick a tag that matches your installed ROCm driver best; this one is a good default.
FROM rocm/pytorch:rocm7.1.1_ubuntu22.04_py3.10_pytorch_release_2.9.1

# OCI metadata for discoverability
LABEL org.opencontainers.image.source="https://github.com/zuzupebbles/unsloth-rocm"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/zuzupebbles/unsloth-rocm"
LABEL org.opencontainers.image.title="Unsloth ROCm image"
LABEL org.opencontainers.image.description="Unsloth + ROCm PyTorch for AMD GPUs (e.g. 7900 XTX)"
LABEL org.opencontainers.image.licenses="Apache-2.0"

# Basic utilities
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        git wget curl vim nano && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Unsloth (AMD is supported via regular pip install)
# Unsloth itself is Apache-2.0 licensed.
RUN pip install --upgrade pip && \
    pip install --no-cache-dir unsloth

# Optional: tools you’ll almost certainly want when experimenting
RUN pip install --no-cache-dir \
      "transformers>=4.45.0" \
      datasets \
      accelerate \
      peft \
      safetensors \
      bitsandbytes  || true
# ^ bitsandbytes may be CUDA-only; failing here is fine, Unsloth on ROCm does not strictly need it.

# Create a non-root user that matches your host UID/GID at runtime (set via docker-compose)
ARG USERNAME=unsloth
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${USERNAME} && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME}

USER ${USERNAME}
WORKDIR /workspace

# Keep the container alive by default; you’ll exec into it
CMD ["bash"]
