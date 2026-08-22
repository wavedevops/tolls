#!/bin/bash

# Make scripts executable
chmod +x 01.kind.sh 02.compile.sh 03.commands.sh

set -e  # Stop if any command fails

# Colors
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# On any error
trap 'echo "${RED}❌ ERROR: One script failed. Stopping execution.${RESET}"' ERR

echo "${BLUE}▶ Running 01.kind.sh...${RESET}"
bash ./01.kind.sh

echo "${BLUE}▶ Running 02.compile.sh...${RESET}"
bash ./02.compile.sh

echo "${BLUE}▶ Running 03.commands.sh...${RESET}"
bash ./03.commands.sh

echo "${GREEN}✅ All scripts executed successfully!${RESET}"

echo "${GREEN}👉 Run this command:${RESET} ${YELLOW}source ~/.bashrc${RESET}"