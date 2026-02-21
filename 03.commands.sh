#!/bin/bash

NAMESPACE="prasad"





# echo "alias k=kubectl" >> ~/.bashrc
# source ~/.bashrc


kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
kubectl config set-context --current --namespace="${NAMESPACE}"



