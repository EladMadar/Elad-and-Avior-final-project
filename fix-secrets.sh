#!/bin/bash

# Generate a secure Django secret key
DJANGO_SECRET_KEY=$(openssl rand -base64 32)

# RDS endpoint
DB_HOST="status-page-prod-db.cx248m4we6k7.us-east-1.rds.amazonaws.com"

# Generate a temporary database password
DB_PASSWORD=$(openssl rand -base64 16)

# Create a temporary k8s secret file with the correct key names
cat > k8s/updated-secrets.yaml << EOL
apiVersion: v1
kind: Secret
metadata:
  name: statuspage-secrets
  namespace: statuspage
type: Opaque
stringData:
  database-url: "postgresql://postgres:${DB_PASSWORD}@${DB_HOST}:5432/postgres"
  redis-url: "redis://status-page-prod-redis.internal:6379/0"
  django-secret-key: "${DJANGO_SECRET_KEY}"
  AWS_ACCESS_KEY_ID: "$(aws configure get aws_access_key_id)"
  AWS_SECRET_ACCESS_KEY: "$(aws configure get aws_secret_access_key)"
  AWS_REGION: "us-east-1"
EOL

echo "Updated secret file generated at k8s/updated-secrets.yaml"
