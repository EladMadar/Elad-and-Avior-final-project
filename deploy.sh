#!/bin/bash
set -e

# Configuration
AWS_REGION="us-east-1"
PROJECT_NAME="statuspage"
ENV="prod"

# Ensure AWS CLI is configured
if ! aws sts get-caller-identity &>/dev/null; then
    echo "Error: AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Step 1: Apply Terraform Infrastructure
echo "🏗️  Applying Terraform infrastructure..."
cd terraform/environments/${ENV}
terraform init
terraform apply -auto-approve

# Get infrastructure outputs
EKS_CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
ECR_REGISTRY=$(terraform output -raw ecr_registry)

# Step 2: Configure kubectl
echo "🔧 Configuring kubectl..."
aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME}

# Step 3: Build and push Docker images
echo "🐳 Building and pushing Docker images..."
export ECR_REGISTRY
export IMAGE_TAG=$(git rev-parse --short HEAD)

# Login to ECR
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}

# Build and push images
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml push

# Step 4: Apply Kubernetes manifests
echo "🚀 Deploying to Kubernetes..."
cd ../../../k8s

# Update image tags in manifests
for file in *.yaml; do
    sed -i '' "s|image: .*statuspage-.*|image: ${ECR_REGISTRY}/statuspage-\$\{COMPONENT\}:${IMAGE_TAG}|g" $file
done

# Apply manifests
kubectl apply -f namespace.yaml
kubectl apply -f secrets.yaml
kubectl apply -f configmap.yaml
kubectl apply -f web-deployment.yaml
kubectl apply -f worker-deployment.yaml
kubectl apply -f celery-deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml

# Step 5: Wait for deployment
echo "⏳ Waiting for deployment to complete..."
kubectl rollout status deployment/statuspage-web -n statuspage
kubectl rollout status deployment/statuspage-worker -n statuspage
kubectl rollout status deployment/statuspage-celery -n statuspage

# Get the ALB URL
ALB_URL=$(kubectl get ingress -n statuspage statuspage-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "✅ Deployment complete!"
echo "🌐 Your status page is accessible at: https://${ALB_URL}"
echo "⚠️  Note: It might take a few minutes for DNS to propagate"
