
#!/bin/bash

# # Install bash completion
# sudo apt update && sudo apt install -y bash-completion

# # Setup kubectl completion and alias in ~/.bashrc
# cat << 'EOF' >> ~/.bashrc

# # Kubectl completion and alias
# source <(kubectl completion bash)
# alias k=kubectl
# complete -o default -F __start_kubectl k
# EOF

# # Apply changes to the current session
# source /usr/share/bash-completion/bash_completion
# source <(kubectl completion bash)
# alias k=kubectl
# complete -o default -F __start_kubectl k

# echo "✅ Done! Alias 'k' with completion is ready. Try: k get nodes"
#############

LOG_FILE="/tmp/kubectl-setup.log"

# Save all output to log file, but keep terminal for step messages
exec 3>&1 4>&2
exec >"$LOG_FILE" 2>&1

step() {
  echo "$1" >&3
}

step "📄 Logging full output to $LOG_FILE"
step "🔧 Installing bash-completion..."
sudo apt update && sudo apt install -y bash-completion

step "⚙️  Setting up kubectl completion and alias..."

cat << 'EOF' >> ~/.bashrc

# Kubectl completion and alias
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
EOF

# Apply changes to current session
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k

step "✅ Done! Alias 'k' with completion is ready. Try: k get nodes"
step "📄 Full log saved at: $LOG_FILE"
