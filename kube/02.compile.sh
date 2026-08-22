#!/bin/bash
set -e  # Exit immediately if any command fails

LOG_FILE="/tmp/kubectl-setup.log"

# Colors
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

# If any error happens, print message in RED
trap 'echo "${RED}❌ ERROR occurred. Check log file: $LOG_FILE${RESET}" >&3' ERR

# Save all output to log file, but keep terminal for step messages
exec 3>&1 4>&2
exec >"$LOG_FILE" 2>&1

step() {
  echo "${BLUE}$1${RESET}" >&3
}

step "📄 Logging full output to $LOG_FILE"

step "🔧 Installing bash-completion..."
sudo apt-get update
sudo apt-get install -y bash-completion

step "⚙️  Setting up kubectl completion and alias..."

cat << 'EOF' >> ~/.bashrc

# Kubectl completion and alias
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
EOF

# Apply changes to current session (ignore errors here safely)
source /usr/share/bash-completion/bash_completion || true
source <(kubectl completion bash) || true
alias k=kubectl
complete -o default -F __start_kubectl k

# Restore stdout/stderr
exec 1>&3 2>&4

echo "${GREEN}✅ SUCCESS: Done! Alias 'k' with completion is ready.${RESET}"
echo "${GREEN}ℹ️  Please run: source ~/.bashrc  (or open a new terminal)${RESET}"
echo "${GREEN}📄 Full log saved at: $LOG_FILE${RESET}"