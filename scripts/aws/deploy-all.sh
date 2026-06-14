#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/create-ecr.sh"
"${SCRIPT_DIR}/push-image.sh"
"${SCRIPT_DIR}/deploy-stack.sh"
