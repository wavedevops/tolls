#!/bin/bash

NAMESPACE="prasad"

sudo apt update
sudo apt install -y bash-completion

kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null

source ~/.bashrc

# echo "alias k=kubectl" >> ~/.bashrc
# source ~/.bashrc


kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
kubectl config set-context --current --namespace="${NAMESPACE}"



