#!/bin/bash

# Install bash completion if not present
sudo apt update
sudo apt install -y bash-completion

# Enable kubectl completion
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null

# Add alias and completion to ~/.bashrc if not already added
grep -qxF 'alias k=kubectl' ~/.bashrc || echo 'alias k=kubectl' >> ~/.bashrc
grep -qxF 'complete -F __start_kubectl k' ~/.bashrc || echo 'complete -F __start_kubectl k' >> ~/.bashrc

# Reload bashrc
source ~/.bashrc

echo "✅ Done! Now try: k get i  and press TAB"
