#!/bin/bash

set -e

CLUSTER_NAME="k8s-cluster"
CONFIG_FILE="main.yaml"
CONTEXT_NAME="kind-${CLUSTER_NAME}"

LOG_FILE="$(mktemp /tmp/kind-setup-XXXX.log)"

# Send all command output to log file
exec 3>&1 4>&2
exec >"$LOG_FILE" 2>&1

step() {
  # Print progress to terminal only
  echo "$1" >&3
}

step "🚀 Step 1/8: Checking Docker..."
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker not installed" >&2
  exit 1
fi

step "📦 Step 2/8: Checking/Installing kind..."
if ! command -v kind >/dev/null 2>&1; then
  curl -Lo kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
  chmod +x kind
  sudo mv kind /usr/local/bin/kind
fi

step "🧰 Step 3/8: Checking/Installing kubectl..."
if ! command -v kubectl >/dev/null 2>&1; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/kubectl
fi

step "📄 Step 4/8: Creating config file if needed..."
if [ ! -f "$CONFIG_FILE" ]; then
  cat <<EOF > $CONFIG_FILE
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
EOF
fi

step "⚙️ Step 5/8: Creating KIND cluster if not exists..."
if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG_FILE"
fi

step "🔧 Step 6/8: Setting kubectl context..."
kubectl config use-context "$CONTEXT_NAME" >/dev/null 2>&1 || true

step "📡 Step 7/8: Checking cluster status..."
kubectl cluster-info --context "$CONTEXT_NAME"
kubectl get pods || true
kubectl get pods -A

step "✅ Step 8/8: Done!"

# Restore stdout/stderr
exec 1>&3 2>&4

echo "✅ Completed. Detailed logs saved in: $LOG_FILE"

