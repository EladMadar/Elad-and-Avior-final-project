#!/bin/bash
set -e

# Configuration
NAMESPACE="statuspage"

# Generate a secure Django secret key
DJANGO_SECRET_KEY=$(openssl rand -base64 32)

# Get database information from AWS Secrets Manager
DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id statuspage-db-password --query SecretString --output text || echo "db-password-placeholder")

# Create the Kubernetes secrets
cat <<EOT | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: statuspage-secrets
  namespace: $NAMESPACE
type: Opaque
stringData:
  database-url: "postgresql://postgres:${DB_PASSWORD}@statuspage-db.internal:5432/statuspage"
  redis-url: "redis://statuspage-redis.internal:6379/0"
  django-secret-key: "${DJANGO_SECRET_KEY}"
  # Add other secrets as needed
EOT

echo "Secrets created successfully!"
