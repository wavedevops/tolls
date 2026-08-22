#!/bin/bash

set -euo pipefail

LOG_FILE="/tmp/kubectl-setup.log"
BASHRC="$HOME/.bashrc"

GREEN=$(tput setaf 2 2>/dev/null || true)
RED=$(tput setaf 1 2>/dev/null || true)
BLUE=$(tput setaf 4 2>/dev/null || true)
YELLOW=$(tput setaf 3 2>/dev/null || true)
RESET=$(tput sgr0 2>/dev/null || true)

# --------------------------------------------------
# Logging
# --------------------------------------------------

exec 3>&1 4>&2
exec >"$LOG_FILE" 2>&1

step() {
    echo "${BLUE}$1${RESET}" >&3
}

fail() {
    echo "${RED}❌ ERROR: $1${RESET}" >&3
    echo "${YELLOW}📄 Check log: $LOG_FILE${RESET}" >&3
    exit 1
}

trap 'fail "Something went wrong."' ERR

# --------------------------------------------------
# Check kubectl
# --------------------------------------------------

step "🔍 Checking kubectl..."

if ! command -v kubectl >/dev/null 2>&1; then
    fail "kubectl is not installed."
fi

echo "kubectl: $(command -v kubectl)"

# --------------------------------------------------
# Install bash-completion
# --------------------------------------------------

step "🔧 Installing bash-completion..."

sudo apt-get update
sudo apt-get install -y bash-completion

# --------------------------------------------------
# Configure ~/.bashrc
# --------------------------------------------------

step "⚙️ Configuring kubectl completion and alias..."

if ! grep -qF "# KUBECTL_SETUP_START" "$BASHRC"; then

    cat >> "$BASHRC" <<'EOF'

# KUBECTL_SETUP_START
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
# KUBECTL_SETUP_END
EOF

    step "✅ Added kubectl configuration to ~/.bashrc"

else

    step "ℹ️ kubectl configuration already exists in ~/.bashrc"

fi

# --------------------------------------------------
# Configure current child shell
# --------------------------------------------------

step "🔄 Enabling kubectl completion..."

source /usr/share/bash-completion/bash_completion 2>/dev/null || true
source <(kubectl completion bash)

alias k=kubectl
complete -o default -F __start_kubectl k

# --------------------------------------------------
# Restore terminal
# --------------------------------------------------

exec 1>&3 2>&4

echo
echo "${GREEN}✅ SUCCESS: kubectl configuration completed.${RESET}"
echo "${GREEN}📌 Alias:${RESET} k=kubectl"
echo "${GREEN}📌 Completion:${RESET} enabled"
echo "${GREEN}📄 Log:${RESET} ${LOG_FILE}"
echo
echo "${YELLOW}👉 Run:${RESET} source ~/.bashrc"