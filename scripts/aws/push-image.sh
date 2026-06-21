#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${SCRIPT_DIR}/config.env"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
REPOSITORY_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}"
IMAGE_URI="${REPOSITORY_URI}:${IMAGE_TAG}"
DOCKER_PLATFORM="${DOCKER_PLATFORM:-linux/amd64}"

aws ecr get-login-password --region "${AWS_REGION}" | \
  docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

docker build --platform "${DOCKER_PLATFORM}" -t "${PROJECT_NAME}:${IMAGE_TAG}" "${PROJECT_ROOT}"
docker tag "${PROJECT_NAME}:${IMAGE_TAG}" "${IMAGE_URI}"
docker push "${IMAGE_URI}"

echo "${IMAGE_URI}"
