#!/bin/bash

set -e

chmod +x 01.kind.sh 02.compile.sh 03.commands.sh

GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

trap 'echo "${RED}❌ ERROR: Setup failed. Stopping execution.${RESET}"' ERR

echo "${BLUE}▶ Running 01.kind.sh...${RESET}"
./01.kind.sh

echo "${BLUE}▶ Running 02.compile.sh...${RESET}"
./02.compile.sh

echo "${BLUE}▶ Running 03.commands.sh...${RESET}"
./03.commands.sh

echo
echo "${GREEN}✅ All scripts executed successfully!${RESET}"
echo
echo "${YELLOW}👉 Run:${RESET} source ~/.bashrc"
echo