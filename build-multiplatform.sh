#!/bin/bash
set -e

# Configuration
ECR_REPOSITORY="elad-avior-statuspage-web"
ECR_URI="992382545251.dkr.ecr.us-east-1.amazonaws.com"
FULL_IMAGE_NAME="$ECR_URI/$ECR_REPOSITORY"

echo "Building multi-platform Status Page application image..."

# Create and use a builder with multi-platform support
docker buildx create --name multiplatform-builder --use

# Build the Docker image with multi-platform support
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg METRICS_ENABLED=true \
  --build-arg MONITORING_RETENTION_DAYS=14 \
  -t $FULL_IMAGE_NAME:latest \
  --push \
  -f Dockerfile .

echo "Multi-platform image pushed successfully!"

echo "Updating Kubernetes deployments to use the new image..."
kubectl rollout restart deployment/statuspage-web deployment/statuspage-worker deployment/statuspage-celery -n statuspage

echo "Deployments restarted! Monitoring rollout status..."
