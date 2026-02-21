#!/bin/bash
chmod +x 01.kind.sh 02.compile.sh 03.commands.sh

set -e  # Stop if any command fails

echo "Running 01.kind.sh..."
bash ./01.kind.sh

echo "Running 02.compile.sh..."
bash ./02.compile.sh

echo "Running 03.commands.sh..."
bash ./03.commands.sh

echo "All scripts executed successfully!"
