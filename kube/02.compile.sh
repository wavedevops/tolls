#!/bin/bash

set -e

LOG_FILE="/tmp/kubectl-setup.log"
BASHRC="$HOME/.bashrc"

exec 3>&1 4>&2
exec >"$LOG_FILE" 2>&1

step() {
    echo "$1" >&3
}

trap 'echo "❌ Error occurred. Check log: $LOG_FILE" >&3; exit 1' ERR

step "📄 Logging full output to $LOG_FILE"

step "🔧 Installing bash-completion..."
sudo apt-get update
sudo apt-get install -y bash-completion

step "⚙️ Setting up kubectl completion and alias..."

if ! grep -q "# KUBECTL_SETUP_START" "$BASHRC"; then
cat >> "$BASHRC" <<'EOF'

# KUBECTL_SETUP_START
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
# KUBECTL_SETUP_END
EOF
    step "✅ Added kubectl configuration to $BASHRC"
else
    step "ℹ️ kubectl configuration already exists in $BASHRC"
fi

source /usr/share/bash-completion/bash_completion 2>/dev/null || true
source <(kubectl completion bash) 2>/dev/null || true
alias k=kubectl
complete -o default -F __start_kubectl k

exec 1>&3 2>&4

echo
echo "✅ kubectl shell configuration completed."
echo "📌 Alias: k=kubectl"
echo "📌 Completion: enabled"
echo "📄 Log: $LOG_FILE"
echo
echo "👉 Run: source ~/.bashrc"
