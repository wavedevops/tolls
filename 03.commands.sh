#!/usr/bin/env bash
#
# 03.commands.sh — Cheat-sheet of useful KIND / kubectl commands
#
# This file is meant to be sourced, not executed, so you can call
# the functions directly from your shell:
#
#   source 03.commands.sh
#   kind-list
#   kind-nodes dev-cluster
#
# Running it directly (./03.commands.sh) just prints the same list.
#
set -uo pipefail

# List all KIND clusters
kind-list() {
  kind get clusters
}

# Show nodes for a given cluster (defaults to current kubectl context)
kind-nodes() {
  local cluster="${1:-}"
  if [[ -n "${cluster}" ]]; then
    kubectl get nodes --context "kind-${cluster}"
  else
    kubectl get nodes
  fi
}

# Delete a cluster by name
kind-delete() {
  local cluster="${1:?Usage: kind-delete <cluster-name>}"
  kind delete cluster --name "${cluster}"
}

# View pods across all namespaces for a given cluster
kind-pods-all() {
  local cluster="${1:-}"
  if [[ -n "${cluster}" ]]; then
    kubectl get pods -A --context "kind-${cluster}"
  else
    kubectl get pods -A
  fi
}

# Print a quick reference of raw commands (used when script is run, not sourced)
print_reference() {
  cat <<'EOF'

Useful KIND / kubectl commands
-------------------------------
# List clusters
kind get clusters

# Show nodes
kubectl get nodes

# Delete cluster
kind delete cluster --name dev-cluster

# View pods (all namespaces)
kubectl get pods -A

# Switch kubectl context between clusters
kubectl config get-contexts
kubectl config use-context kind-<cluster-name>

# Load a local Docker image into a KIND cluster (no registry push needed)
kind load docker-image <image:tag> --name <cluster-name>

EOF
}

# If executed directly (not sourced), just print the reference.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  print_reference
fi
