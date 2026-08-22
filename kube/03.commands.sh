#!/bin/bash

set -euo pipefail

NAMESPACE="prasad"
LOG_FILE="/tmp/kubectl-commands.log"

exec 3>&1 4>&2
exec >"$LOG_FILE" 2>&1

step() {
    echo "$1" >&3
}

fail() {
    echo "❌ ERROR: $1" >&3
    echo "📄 Check log: $LOG_FILE" >&3
    exit 1
}

trap 'fail "Something went wrong."' ERR

step "🔍 Step 1/5: Checking kubectl..."

if ! command -v kubectl >/dev/null 2>&1; then
    fail "kubectl is not installed."
fi

step "✅ kubectl found: $(command -v kubectl)"

step "📡 Step 2/5: Checking Kubernetes cluster..."

if ! kubectl cluster-info >/dev/null 2>&1; then
    fail "Kubernetes cluster is not reachable."
fi

step "✅ Kubernetes cluster is running."

step "📦 Step 3/5: Creating namespace '$NAMESPACE'..."

kubectl create namespace "$NAMESPACE" \
    --dry-run=client \
    -o yaml | kubectl apply -f -

step "✅ Namespace '$NAMESPACE' is ready."

step "⚙️ Step 4/5: Setting default namespace..."

kubectl config set-context --current \
    --namespace="$NAMESPACE" >/dev/null

step "✅ Default namespace set to '$NAMESPACE'."

step "🔎 Step 5/5: Verifying setup..."

echo >&3
kubectl get namespace "$NAMESPACE" >&3

echo >&3
kubectl config view \
    --minify \
    --output 'jsonpath={..namespace}' >&3
echo >&3

kubectl get nodes >&3

exec 1>&3 2>&4

echo
echo "=============================================="
echo "✅ COMMAND SETUP COMPLETED"
echo "=============================================="
echo "Namespace : $NAMESPACE"
echo "Log file  : $LOG_FILE"
echo "=============================================="
