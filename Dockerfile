FROM --platform=linux/arm64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive 
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential cmake wget \
      gromacs \
      python3 python3-pip python3-dev \
      git \
 && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir \
      --upgrade pip \
      numpy scipy pandas scikit-learn \
      jupyterlab tensorflow torch

WORKDIR /workspace
COPY scripts/ ./scripts/

RUN useradd --create-home dev \
 && chown -R dev:dev /workspace
USER dev
ENV HOME=/home/dev

ENTRYPOINT ["bash"]
