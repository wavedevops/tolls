#!/bin/bash

set -e

# ============================================================
# Kubernetes KIND - Run All Scripts
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCRIPT_1="$SCRIPT_DIR/01.kind.sh"
SCRIPT_2="$SCRIPT_DIR/02.compile.sh"
SCRIPT_3="$SCRIPT_DIR/03.commands.sh"

# ============================================================
# Colors
# ============================================================

GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# ============================================================
# Error Handler
# ============================================================

trap 'echo "${RED}❌ ERROR: Script failed. Execution stopped.${RESET}"' ERR

# ============================================================
# Check Scripts
# ============================================================

echo "${BLUE}🔍 Checking scripts...${RESET}"

for SCRIPT in "$SCRIPT_1" "$SCRIPT_2" "$SCRIPT_3"; do
    if [ ! -f "$SCRIPT" ]; then
        echo "${RED}❌ Missing script: $SCRIPT${RESET}"
        exit 1
    fi
done

chmod +x "$SCRIPT_1" "$SCRIPT_2" "$SCRIPT_3"

echo "${GREEN}✅ All scripts found.${RESET}"
echo

# ============================================================
# STEP 1 - Docker Cleanup
# ============================================================

echo "${BLUE}==============================================${RESET}"
echo "${BLUE}🧹 STEP 1/4: Removing Docker containers${RESET}"
echo "${BLUE}==============================================${RESET}"

docker rm -f $(docker ps -aq) 2>/dev/null || true

echo "${GREEN}✅ Docker container cleanup completed.${RESET}"
echo

# ============================================================
# STEP 2 - KIND Setup
# ============================================================

echo "${BLUE}==============================================${RESET}"
echo "${BLUE}🚀 STEP 2/4: KIND Setup${RESET}"
echo "${BLUE}==============================================${RESET}"

bash "$SCRIPT_1"

echo "${GREEN}✅ STEP 2 completed.${RESET}"
echo

# ============================================================
# STEP 3 - kubectl Setup
# ============================================================

echo "${BLUE}==============================================${RESET}"
echo "${BLUE}🚀 STEP 3/4: kubectl Setup${RESET}"
echo "${BLUE}==============================================${RESET}"

bash "$SCRIPT_2"

echo "${GREEN}✅ STEP 3 completed.${RESET}"
echo

# ============================================================
# STEP 4 - Kubernetes Commands
# ============================================================

echo "${BLUE}==============================================${RESET}"
echo "${BLUE}🚀 STEP 4/4: Kubernetes Commands${RESET}"
echo "${BLUE}==============================================${RESET}"

bash "$SCRIPT_3"

echo "${GREEN}✅ STEP 4 completed.${RESET}"
echo

# ============================================================
# COMPLETE
# ============================================================

echo "${GREEN}==============================================${RESET}"
echo "${GREEN}🎉 ALL STEPS COMPLETED SUCCESSFULLY!${RESET}"
echo "${GREEN}==============================================${RESET}"

echo
echo "${YELLOW}👉 If kubectl alias/completion was configured:${RESET}"
echo "${YELLOW}   source ~/.bashrc${RESET}"
echo

echo "${BLUE}Current Kubernetes context:${RESET}"
kubectl config current-context

echo
echo "${BLUE}Kubernetes nodes:${RESET}"
kubectl get nodes