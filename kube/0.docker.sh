#!/bin/bash

set -e

echo "========================================="
echo "🐳 Docker Setup"
echo "========================================="

echo
echo "📦 Updating packages..."
sudo apt update

echo
echo "📦 Installing Docker..."
sudo apt install -y docker.io

echo
echo "🔄 Starting Docker..."
sudo systemctl enable --now docker

echo
echo "👤 Adding $USER to docker group..."
sudo usermod -aG docker "$USER"

echo
echo "✅ Docker service status:"
sudo systemctl is-active docker

echo
echo "✅ Docker version:"
docker --version

echo
echo "========================================="
echo "✅ Docker installation completed!"
echo "========================================="

echo
echo "⚠️ Important:"
echo "Log out and log back in, or run:"
echo
echo "    newgrp docker"
echo
echo "Then verify with:"
echo
echo "    docker run hello-world"
echo