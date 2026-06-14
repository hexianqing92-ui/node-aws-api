#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.env"

aws cloudformation delete-stack \
  --region "${AWS_REGION}" \
  --stack-name "${STACK_NAME}"

echo "Delete requested for ${STACK_NAME}. Watch CloudFormation until DELETE_COMPLETE."
echo "ECR images are not deleted by this script. Delete the ${PROJECT_NAME} repository manually if you no longer need it."
