#!/bin/bash
set -e

# Configuration
ECR_REPOSITORY="elad-avior-statuspage-web"
ECR_URI="992382545251.dkr.ecr.us-east-1.amazonaws.com"
FULL_IMAGE_NAME="$ECR_URI/$ECR_REPOSITORY"

echo "Building the Status Page application image..."

# Build the Docker image with monitoring support
docker build \
  --build-arg METRICS_ENABLED=true \
  --build-arg MONITORING_RETENTION_DAYS=14 \
  -t $FULL_IMAGE_NAME:latest \
  -f Dockerfile .

echo "Pushing image to ECR repository..."
docker push $FULL_IMAGE_NAME:latest

echo "Image pushed successfully!"

echo "Updating Kubernetes deployments to use the new image..."
sed -i '' "s|image:.*|image: $FULL_IMAGE_NAME:latest|g" k8s/web-deployment.yaml
sed -i '' "s|image:.*|image: $FULL_IMAGE_NAME:latest|g" k8s/worker-deployment.yaml
sed -i '' "s|image:.*|image: $FULL_IMAGE_NAME:latest|g" k8s/celery-deployment.yaml

echo "Deployment files updated! Ready to apply with kubectl."
