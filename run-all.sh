#!/usr/bin/env bash
#
# run-all.sh — Full KIND setup: install tools, create cluster, deploy test app
#
# Usage:
#   ./run-all.sh              # single-node dev cluster (default)
#   ./run-all.sh multi        # multi-node cluster instead
#   ./run-all.sh both         # both single and multi-node clusters
#
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="${1:-single}"

echo "=============================================="
echo " Step 1/3: Installing Docker, kubectl, KIND"
echo "=============================================="
bash "${DIR}/01.kind.sh"

echo "=============================================="
echo " Step 2/3: Creating cluster(s) [mode=${MODE}]"
echo "=============================================="
bash "${DIR}/02.compile.sh" "${MODE}"

echo "=============================================="
echo " Step 3/3: Reference commands"
echo "=============================================="
bash "${DIR}/03.commands.sh"

echo
echo "All done. Your KIND cluster(s) should now be running."
echo "Run 'kind get clusters' to confirm."
