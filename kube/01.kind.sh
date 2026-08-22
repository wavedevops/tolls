#!/bin/bash

set -e

CLUSTER_NAME="k8s-cluster"
CONFIG_FILE="main.yaml"
CONTEXT_NAME="kind-${CLUSTER_NAME}"

LOG_FILE="$(mktemp /tmp/kind-setup-XXXXXX.log)"

exec 3>&1 4>&2
exec >"$LOG_FILE" 2>&1

step() {
    echo "$1" >&3
}

trap 'echo "❌ Error occurred. Check log: $LOG_FILE" >&3; exit 1' ERR

step "🚀 Step 1/9: Checking Docker..."

if ! command -v docker >/dev/null 2>&1; then
    echo "❌ Docker is not installed." >&2
    echo "Please install Docker first." >&2
    exit 1
fi

if ! sudo systemctl is-active --quiet docker; then
    step "🔄 Starting Docker..."
    sudo systemctl enable --now docker
fi

step "✅ Docker is ready."

step "📦 Step 2/9: Checking/Installing Kind..."

if ! command -v kind >/dev/null 2>&1; then
    KIND_VERSION="v0.29.0"

    curl -Lo /tmp/kind \
        "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"

    chmod +x /tmp/kind
    sudo mv /tmp/kind /usr/local/bin/kind
fi

step "✅ Kind version: $(kind version)"

step "🧰 Step 3/9: Checking/Installing kubectl..."

if ! command -v kubectl >/dev/null 2>&1; then
    KUBECTL_VERSION="$(curl -L -s https://dl.k8s.io/release/stable.txt)"

    curl -LO \
        "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/kubectl
    rm -f kubectl
fi

step "✅ kubectl version:"
kubectl version --client

step "📄 Step 4/9: Creating Kind configuration..."

if [ ! -f "$CONFIG_FILE" ]; then
cat > "$CONFIG_FILE" <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

nodes:
  - role: control-plane
  - role: worker
  - role: worker
  - role: worker
EOF
    step "✅ Created $CONFIG_FILE"
else
    step "ℹ️ $CONFIG_FILE already exists."
fi

step "⚙️ Step 5/9: Creating Kind cluster..."

if ! kind get clusters | grep -qx "$CLUSTER_NAME"; then
    kind create cluster \
        --name "$CLUSTER_NAME" \
        --config "$CONFIG_FILE"
else
    step "ℹ️ Cluster '$CLUSTER_NAME' already exists."
fi

step "🔧 Step 6/9: Setting kubectl context..."

kubectl config use-context "$CONTEXT_NAME" >/dev/null
step "✅ Current context: $CONTEXT_NAME"

step "📡 Step 7/9: Checking cluster status..."

kubectl cluster-info --context "$CONTEXT_NAME"

echo >&3
kubectl get nodes >&3

step "🏷️ Step 8/9: Labeling worker nodes..."

WORKERS=$(kubectl get nodes \
    --no-headers \
    -o custom-columns=":metadata.name" \
    | grep -v "control-plane" || true)

i=1

for node in $WORKERS; do
    kubectl label node "$node" \
        "node-name=node$i" \
        --overwrite
    step "✅ $node → node-name=node$i"
    i=$((i + 1))
done

echo >&3
kubectl get nodes --show-labels >&3

step "✅ Step 9/9: Kind cluster setup completed!"

exec 1>&3 2>&4

echo
echo "=============================================="
echo "✅ KIND CLUSTER READY"
echo "=============================================="
echo "Cluster : $CLUSTER_NAME"
echo "Context : $CONTEXT_NAME"
echo "Workers : 3"
echo
echo "Log file:"
echo "$LOG_FILE"
echo "=============================================="
