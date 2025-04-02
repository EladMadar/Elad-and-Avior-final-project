#!/bin/bash

# Generate a secure Django secret key
DJANGO_SECRET_KEY=$(openssl rand -base64 32)

# RDS endpoint we already obtained
DB_HOST="status-page-prod-db.cx248m4we6k7.us-east-1.rds.amazonaws.com"

# Generate a temporary database password (to be changed later through proper channels)
DB_PASSWORD=$(openssl rand -base64 16)

# Get AWS credentials from current session
AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)

# Create a temporary k8s secret file
cat > k8s/generated-secrets.yaml << EOL
apiVersion: v1
kind: Secret
metadata:
  name: statuspage-secrets
  namespace: statuspage
type: Opaque
stringData:
  DATABASE_URL: "postgresql://postgres:${DB_PASSWORD}@${DB_HOST}:5432/postgres"
  REDIS_URL: "redis://status-page-prod-redis.internal:6379/0"
  DJANGO_SECRET_KEY: "${DJANGO_SECRET_KEY}"
  AWS_ACCESS_KEY_ID: "${AWS_ACCESS_KEY_ID}"
  AWS_SECRET_ACCESS_KEY: "${AWS_SECRET_ACCESS_KEY}"
  AWS_REGION: "us-east-1"
EOL

echo "Secret file generated at k8s/generated-secrets.yaml"
