
#!/bin/bash

# Install bash completion
sudo apt update && sudo apt install -y bash-completion

# Setup kubectl completion and alias in ~/.bashrc
cat << 'EOF' >> ~/.bashrc

# Kubectl completion and alias
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
EOF

# Apply changes to the current session
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k

echo "✅ Done! Alias 'k' with completion is ready. Try: k get nodes"
