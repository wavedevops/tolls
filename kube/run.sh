#!/bin/bash

set -e

echo "========================================="
echo " Kubernetes Kind Setup"
echo "========================================="

chmod +x 01.kind.sh 02.compile.sh 03.commands.sh

echo
echo "🚀 Running 01.kind.sh..."
bash ./01.kind.sh

echo
echo "🔧 Running 02.compile.sh..."
bash ./02.compile.sh

echo
echo "⚙️ Running 03.commands.sh..."
bash ./03.commands.sh

echo
echo "========================================="
echo "✅ All scripts executed successfully!"
echo "========================================="

echo
echo "Run this command to reload kubectl alias:"
echo -e "\e[1;33msource ~/.bashrc\e[0m"
echo
