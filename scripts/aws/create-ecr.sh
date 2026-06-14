#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.env"

aws ecr describe-repositories \
  --repository-names "${PROJECT_NAME}" \
  --region "${AWS_REGION}" >/dev/null 2>&1 || \
aws ecr create-repository \
  --repository-name "${PROJECT_NAME}" \
  --image-scanning-configuration scanOnPush=true \
  --region "${AWS_REGION}" >/dev/null

aws ecr describe-repositories \
  --repository-names "${PROJECT_NAME}" \
  --region "${AWS_REGION}" \
  --query "repositories[0].repositoryUri" \
  --output text
