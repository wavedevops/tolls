#!/bin/bash
set -e

LOG_FILE="/tmp/kubectl-setup.log"
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

exec 3>&1 4>&2
exec >"$LOG_FILE" 2>&1
step() { echo "${BLUE}$1${RESET}" >&3; }
trap 'echo "${RED}❌ ERROR: Something went wrong. Check log file: $LOG_FILE${RESET}" >&3' ERR

step "📄 Logging full output to $LOG_FILE"
step "🔧 Installing bash-completion..."
sudo apt-get update
sudo apt-get install -y bash-completion

step "⚙️ Setting up kubectl completion and alias..."
grep -qxF 'source <(kubectl completion bash)' ~/.bashrc || echo 'source <(kubectl completion bash)' >> ~/.bashrc
grep -qxF 'alias k=kubectl' ~/.bashrc || echo 'alias k=kubectl' >> ~/.bashrc
grep -qxF 'complete -o default -F __start_kubectl k' ~/.bashrc || echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc

source /usr/share/bash-completion/bash_completion || true
source <(kubectl completion bash) || true
alias k=kubectl
complete -o default -F __start_kubectl k || true

exec 1>&3 2>&4
echo "${GREEN}✅ SUCCESS: Done! Alias 'k' with completion is ready.${RESET}"
echo "${GREEN}ℹ️ Run: source ~/.bashrc${RESET}"
echo "${GREEN}📄 Full log saved at: $LOG_FILE${RESET}"