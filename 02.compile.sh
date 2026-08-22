#!/usr/bin/env bash
#
# 02.compile.sh — Create KIND cluster(s) and deploy a test application
#
# Usage:
#   ./02.compile.sh single      # single-node dev cluster (default)
#   ./02.compile.sh multi       # 1 control-plane + 2 worker nodes
#   ./02.compile.sh both        # create both clusters
#
set -euo pipefail

log() { echo -e "\n>>> $1\n"; }

MODE="${1:-single}"
SINGLE_CLUSTER="dev-cluster"
MULTI_CLUSTER="multi-node"
CONFIG_FILE="$(dirname "$0")/kind-config.yaml"

create_single_cluster() {
  log "Creating single-node cluster: ${SINGLE_CLUSTER}"
  if kind get clusters | grep -qx "${SINGLE_CLUSTER}"; then
    echo "Cluster '${SINGLE_CLUSTER}' already exists, skipping creation."
  else
    kind create cluster --name "${SINGLE_CLUSTER}"
  fi

  log "Cluster info"
  kubectl cluster-info --context "kind-${SINGLE_CLUSTER}"

  log "Nodes"
  kubectl get nodes

  log "Deploying nginx test app"
  kubectl create deployment nginx --image=nginx --context "kind-${SINGLE_CLUSTER}" \
    || echo "Deployment 'nginx' may already exist, continuing."
  kubectl expose deployment nginx --port=80 --type=NodePort --context "kind-${SINGLE_CLUSTER}" \
    || echo "Service 'nginx' may already exist, continuing."

  log "Pods"
  kubectl get pods --context "kind-${SINGLE_CLUSTER}"

  log "Services"
  kubectl get svc --context "kind-${SINGLE_CLUSTER}"
}

create_multi_node_cluster() {
  log "Writing kind-config.yaml"
  cat > "${CONFIG_FILE}" <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
EOF

  log "Creating multi-node cluster: ${MULTI_CLUSTER}"
  if kind get clusters | grep -qx "${MULTI_CLUSTER}"; then
    echo "Cluster '${MULTI_CLUSTER}' already exists, skipping creation."
  else
    kind create cluster --name "${MULTI_CLUSTER}" --config "${CONFIG_FILE}"
  fi

  log "Nodes"
  kubectl get nodes --context "kind-${MULTI_CLUSTER}"
}

case "${MODE}" in
  single)
    create_single_cluster
    ;;
  multi)
    create_multi_node_cluster
    ;;
  both)
    create_single_cluster
    create_multi_node_cluster
    ;;
  *)
    echo "Unknown mode: ${MODE}"
    echo "Usage: $0 [single|multi|both]"
    exit 1
    ;;
esac

log "Done."
