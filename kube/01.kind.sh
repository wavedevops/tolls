#!/bin/bash

set -euo pipefail

CLUSTER_NAME="k8s-cluster"
CONTEXT_NAME="kind-${CLUSTER_NAME}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/main.yaml"
LOG_FILE="$(mktemp /tmp/kind-setup-XXXXXX.log)"

GREEN=$(tput setaf 2 2>/dev/null || true)
RED=$(tput setaf 1 2>/dev/null || true)
BLUE=$(tput setaf 4 2>/dev/null || true)
YELLOW=$(tput setaf 3 2>/dev/null || true)
RESET=$(tput sgr0 2>/dev/null || true)

exec 3>&1 4>&2
exec >"$LOG_FILE" 2>&1

step() {
    echo "${BLUE}$1${RESET}" >&3
}

fail() {
    echo "${RED}❌ FAILURE: $1${RESET}" >&3
    echo "${YELLOW}📄 Log: ${LOG_FILE}${RESET}" >&3
    exit 1
}

trap 'fail "Something went wrong."' ERR

# --------------------------------------------------
# 1. Dependencies
# --------------------------------------------------

step "🚀 Step 1/9: Checking dependencies..."

command -v docker >/dev/null 2>&1 \
    || fail "Docker is not installed."

command -v curl >/dev/null 2>&1 \
    || fail "curl is not installed."

command -v sudo >/dev/null 2>&1 \
    || fail "sudo is not installed."

docker info >/dev/null 2>&1 \
    || fail "Docker is not running or current user cannot access Docker."

# --------------------------------------------------
# 2. kind
# --------------------------------------------------

step "📦 Step 2/9: Checking kind..."

if ! command -v kind >/dev/null 2>&1; then
    echo "Installing kind..."

    curl -Lo /tmp/kind \
        https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-amd64

    chmod +x /tmp/kind
    sudo mv /tmp/kind /usr/local/bin/kind
fi

kind version

# --------------------------------------------------
# 3. kubectl
# --------------------------------------------------

step "🧰 Step 3/9: Checking kubectl..."

if ! command -v kubectl >/dev/null 2>&1; then
    echo "Installing kubectl..."

    KUBECTL_VERSION="$(curl -L -s https://dl.k8s.io/release/stable.txt)"

    curl -LO \
        "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/kubectl

    rm -f kubectl
fi

kubectl version --client

# --------------------------------------------------
# 4. Kind configuration
# --------------------------------------------------

step "📄 Step 4/9: Creating KIND configuration..."

if [[ ! -f "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

nodes:
  - role: control-plane
  - role: worker
  - role: worker
  - role: worker
EOF

    echo "Created: $CONFIG_FILE"
else
    echo "Using existing: $CONFIG_FILE"
fi

# --------------------------------------------------
# 5. Create cluster
# --------------------------------------------------

step "⚙️ Step 5/9: Creating KIND cluster..."

if kind get clusters | grep -Fxq "$CLUSTER_NAME"; then
    echo "Cluster '${CLUSTER_NAME}' already exists."
else
    kind create cluster \
        --name "$CLUSTER_NAME" \
        --config "$CONFIG_FILE"
fi

# --------------------------------------------------
# 6. Context
# --------------------------------------------------

step "🔧 Step 6/9: Setting kubectl context..."

kubectl config use-context "$CONTEXT_NAME"

# --------------------------------------------------
# 7. Cluster status
# --------------------------------------------------

step "📡 Step 7/9: Checking cluster status..."

kubectl cluster-info --context "$CONTEXT_NAME"

echo
kubectl get nodes -o wide

# --------------------------------------------------
# 8. Label workers
# --------------------------------------------------

step "🏷️ Step 8/9: Labeling worker nodes..."

mapfile -t WORKERS < <(
    kubectl get nodes \
        -l 'node-role.kubernetes.io/control-plane!=' \
        -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
)

if [[ "${#WORKERS[@]}" -eq 0 ]]; then
    fail "No worker nodes found."
fi

i=1

for node in "${WORKERS[@]}"; do
    kubectl label node \
        "$node" \
        "node-name=node${i}" \
        --overwrite

    ((i++))
done

echo
kubectl get nodes --show-labels

# --------------------------------------------------
# 9. Done
# --------------------------------------------------

step "✅ Step 9/9: Done!"

exec 1>&3 2>&4

echo
echo "${GREEN}✅ SUCCESS: KIND cluster '${CLUSTER_NAME}' is ready.${RESET}"
echo "${GREEN}📄 Detailed log: ${LOG_FILE}${RESET}"