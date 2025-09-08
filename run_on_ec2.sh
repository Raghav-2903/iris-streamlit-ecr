#!/usr/bin/env bash
set -euo pipefail
AWS_REGION="${AWS_REGION:-ap-south-1}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-111122223333}"
ECR_REPO_NAME="${ECR_REPO_NAME:-iris-streamlit}"
IMAGE_TAG="${IMAGE_TAG:-v1}"
PORT_ON_EC2="${PORT_ON_EC2:-80}"
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"

if ! command -v docker >/dev/null 2>&1; then
  sudo dnf update -y || true
  sudo dnf install -y docker
  sudo systemctl enable --now docker
  sudo usermod -aG docker $USER || true
fi

aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

docker pull "${ECR_URI}"

set +e
OLD_ID=$(docker ps -q --filter "ancestor=${ECR_URI}") || true
[ -n "${OLD_ID}" ] && docker stop "${OLD_ID}" && docker rm "${OLD_ID}" || true
set -e

docker run -d --restart always -p ${PORT_ON_EC2}:8501 --name iris-app "${ECR_URI}"

IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo "<your-ec2-public-ip>")
echo "App URL: http://${IP}:${PORT_ON_EC2}"
