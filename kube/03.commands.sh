#!/bin/bash

NAMESPACE="prasad"

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
kubectl config set-context --current --namespace="${NAMESPACE}"

kubectl get ns

