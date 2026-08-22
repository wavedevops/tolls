#!/usr/bin/env bash
#
# 01.kind.sh — Install Docker, kubectl, and KIND on Ubuntu
#
set -euo pipefail

log() { echo -e "\n>>> $1\n"; }

KIND_VERSION="v0.32.0"
ARCH="amd64"   # change to arm64 if running on an ARM Ubuntu host

# ---------------------------------------------------------------------------
# 1. Docker
# ---------------------------------------------------------------------------
log "Updating package index"
sudo apt update

log "Installing Docker"
sudo apt install -y docker.io

log "Enabling and starting Docker service"
sudo systemctl enable docker
sudo systemctl start docker

log "Docker version"
docker --version

# ---------------------------------------------------------------------------
# 2. kubectl
# ---------------------------------------------------------------------------
log "Fetching latest stable kubectl version"
KUBECTL_VERSION="$(curl -Ls https://dl.k8s.io/release/stable.txt)"

log "Downloading kubectl ${KUBECTL_VERSION}"
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

log "kubectl client version"
kubectl version --client

# ---------------------------------------------------------------------------
# 3. KIND
# ---------------------------------------------------------------------------
log "Downloading KIND ${KIND_VERSION}"
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${ARCH}"
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

log "KIND version"
kind version

# ---------------------------------------------------------------------------
# 4. Non-root Docker access (optional but recommended)
# ---------------------------------------------------------------------------
log "Adding $USER to the docker group (log out/in or run 'newgrp docker' to apply)"
sudo usermod -aG docker "$USER"

log "Setup complete. If 'docker ps' below fails with a permission error, run:"
echo "    newgrp docker"
echo "or log out and back in, then re-run: docker ps"

docker ps || true
