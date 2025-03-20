# Status Page Infrastructure Guide

## Project Structure

```
status-page/
├── docker/                      # Docker configuration files
│   ├── Dockerfile              # Production Dockerfile
│   ├── Dockerfile.dev          # Development Dockerfile
│   └── Dockerfile.test         # Testing Dockerfile
├── terraform/                   # Infrastructure as Code
│   ├── modules/                # Reusable Terraform modules
│   │   ├── alb/               # Application Load Balancer module
│   │   ├── eks/               # Elastic Kubernetes Service module
│   │   ├── rds/               # RDS PostgreSQL module
│   │   ├── redis/             # ElastiCache Redis module
│   │   ├── vpc/               # VPC networking module
│   │   └── waf/               # Web Application Firewall module
│   ├── environments/           # Environment-specific configurations
│   │   └── prod/              # Production environment
│   └── test-infrastructure.sh  # Infrastructure testing script
├── INFRASTRUCTURE.md           # Detailed infrastructure documentation
└── README.md                   # Project overview
```

## Infrastructure Components

### 1. VPC Module (`terraform/modules/vpc/`)
- Creates a VPC with public, private, and database subnets
- Implements cost-effective NAT Gateway strategy
- Sets up VPC endpoints for reduced data transfer costs
- **Cost Impact**: ~$30-40/month (NAT Gateway)

### 2. EKS Module (`terraform/modules/eks/`)
- Manages Kubernetes cluster with SPOT instances
- Implements cluster autoscaling
- Uses ARM-based instances where possible
- **Cost Impact**: ~$70-100/month

### 3. RDS Module (`terraform/modules/rds/`)
- Sets up PostgreSQL on cost-effective ARM instances
- Manages automated backups and monitoring
- Implements encryption and security
- **Cost Impact**: ~$50-60/month

### 4. Redis Module (`terraform/modules/redis/`)
- Configures ElastiCache with ARM instances
- Implements encryption and security
- **Cost Impact**: ~$30-40/month

### 5. ALB Module (`terraform/modules/alb/`)
- Manages Application Load Balancer
- Handles SSL/TLS termination
- Integrates with WAF
- **Cost Impact**: ~$20-25/month

### 6. WAF Module (`terraform/modules/waf/`)
- Implements security rules and rate limiting
- Manages geo-restrictions
- **Cost Impact**: ~$10-15/month

## Getting Started

### Prerequisites
1. Install required tools:
```bash
# Install AWS CLI
brew install awscli

# Install Terraform
brew install terraform

# Install kubectl
brew install kubectl

# Install helpful tools
brew install infracost tfsec
```

2. Configure AWS credentials:
```bash
aws configure
```

### Deployment Steps

1. **Prepare Configuration**
```bash
# Copy example configuration
cd terraform/environments/prod
cp terraform.tfvars.example terraform.tfvars

# Edit configuration
vim terraform.tfvars
```

2. **Test Infrastructure**
```bash
# Run validation script
./test-infrastructure.sh
```

3. **Deploy Infrastructure**
```bash
# Initialize Terraform
terraform init

# Plan changes
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan
```

4. **Verify Deployment**
```bash
# Configure kubectl
aws eks update-kubeconfig --name status-page-prod-cluster --region us-east-1

# Check nodes
kubectl get nodes

# Check pods
kubectl get pods -A
```

## Cost Optimization

The infrastructure is designed to stay within a $300/month budget while maintaining performance:

1. **Compute Optimization**
   - EKS uses SPOT instances (60-70% savings)
   - ARM-based instances where possible (20% savings)
   - Autoscaling to match demand

2. **Network Optimization**
   - Single NAT Gateway ($30-40/month savings)
   - VPC Endpoints for AWS services
   - Regional data transfer optimization

3. **Storage Optimization**
   - gp3 volumes for better performance/cost
   - Lifecycle policies for logs
   - Automated backup retention

## Testing

1. **Infrastructure Testing**
```bash
# Run full test suite
./test-infrastructure.sh

# Run security checks
tfsec .

# Check costs
infracost breakdown --path .
```

2. **Load Testing**
```bash
# Install k6
brew install k6

# Run load tests
k6 run tests/performance/load-test.js
```

## Monitoring and Alerts

1. **CloudWatch Dashboards**
   - EKS metrics (CPU, Memory, Pods)
   - RDS performance
   - ALB metrics
   - WAF analytics

2. **Cost Monitoring**
   - AWS Cost Explorer integration
   - Budget alerts
   - Resource utilization tracking

## Security

1. **Network Security**
   - Private subnets for workloads
   - Security groups with minimal access
   - WAF protection

2. **Data Security**
   - Encryption at rest
   - TLS for transit
   - Secrets management

## Troubleshooting

Common issues and solutions:

1. **EKS Issues**
   - Check CloudWatch logs
   - Verify node group scaling
   - Review pod metrics

2. **Database Issues**
   - Monitor RDS metrics
   - Check connection pools
   - Review slow queries

3. **Network Issues**
   - Verify security groups
   - Check VPC endpoints
   - Review ALB logs

## Required Changes

Before deploying, you must:

1. Update `terraform.tfvars` with:
   - Your ACM certificate ARN
   - Desired VPC CIDR
   - Any custom tags

2. Configure AWS credentials with appropriate permissions

3. Create an S3 bucket for Terraform state (update `providers.tf`)

4. Update ECR repository details in your Kubernetes manifests

## Support and Maintenance

For issues or questions:
1. Check CloudWatch logs
2. Review INFRASTRUCTURE.md
3. Consult AWS documentation
4. Review cost optimization guide

Remember to regularly:
- Update Terraform providers
- Patch EKS clusters
- Review security groups
- Monitor costs
