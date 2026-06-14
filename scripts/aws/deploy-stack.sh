#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${SCRIPT_DIR}/config.env"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
CONTAINER_IMAGE="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}:${IMAGE_TAG}"

aws cloudformation deploy \
  --region "${AWS_REGION}" \
  --stack-name "${STACK_NAME}" \
  --template-file "${PROJECT_ROOT}/infra/cloudformation/ecs-fargate.yml" \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    ProjectName="${PROJECT_NAME}" \
    EnvironmentName="${ENVIRONMENT_NAME}" \
    ContainerImage="${CONTAINER_IMAGE}" \
    DatabaseName="${DATABASE_NAME}" \
    DatabaseUsername="${DATABASE_USERNAME}" \
    DatabasePassword="${DATABASE_PASSWORD}"

aws cloudformation describe-stacks \
  --region "${AWS_REGION}" \
  --stack-name "${STACK_NAME}" \
  --query "Stacks[0].Outputs" \
  --output table
