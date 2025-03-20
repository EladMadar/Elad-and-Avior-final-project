# Status Page Infrastructure Guide

## Architecture Overview

This infrastructure is designed to run a Django-based status page application on AWS, optimized for both performance and cost (target: under $300/month). The architecture includes:

### Core Components

1. **VPC (Virtual Private Cloud)**
   - 3 public subnets for ALB
   - 3 private subnets for EKS workloads
   - 3 database subnets for RDS
   - Single NAT Gateway (cost optimization)
   - VPC Endpoints for S3 and ECR (reduces data transfer costs)

2. **EKS (Elastic Kubernetes Service)**
   - Uses t3a.medium SPOT instances for cost savings
   - Auto-scaling enabled (min: 1, max: 5 nodes)
   - Cluster Autoscaler for automatic scaling
   - Metrics Server for HPA support
   - Estimated cost: ~$70-100/month

3. **RDS (Relational Database Service)**
   - PostgreSQL 14 on db.t4g.medium (ARM-based for cost efficiency)
   - Automatic backups (7 days for prod, 1 day for other environments)
   - Performance Insights enabled (free tier)
   - Estimated cost: ~$50-60/month

4. **ElastiCache Redis**
   - cache.t4g.medium instance (ARM-based)
   - Single node deployment for cost optimization
   - Encryption at rest and in transit
   - Estimated cost: ~$30-40/month

5. **Application Load Balancer (ALB)**
   - Public-facing load balancer
   - WAF integration for security
   - Access logs stored in S3 with lifecycle policies
   - Estimated cost: ~$20-25/month

6. **WAF (Web Application Firewall)**
   - AWS Managed Rules enabled
   - Rate limiting per IP
   - Geo-restriction capabilities
   - Estimated cost: ~$10-15/month

### Cost Optimization Strategies

1. **Compute Optimization**
   - SPOT instances for EKS nodes
   - ARM-based instances where possible
   - Autoscaling with proper min/max limits

2. **Network Optimization**
   - Single NAT Gateway
   - VPC Endpoints for AWS services
   - Regional data transfer optimization

3. **Storage Optimization**
   - gp3 volumes for better performance/cost ratio
   - S3 lifecycle policies for logs
   - Automated backup retention policies

## Deployment Guide

### Prerequisites
1. AWS CLI configured with appropriate credentials
2. Terraform 1.0.0 or later installed
3. kubectl installed
4. helm installed

### Initial Setup

1. **Configure AWS Credentials**
   ```bash
   aws configure
   ```

2. **Initialize Terraform Backend**
   - Create an S3 bucket for Terraform state
   - Create a DynamoDB table for state locking
   - Update backend configuration in providers.tf

3. **Configure Variables**
   ```bash
   cp terraform/environments/prod/terraform.tfvars.example terraform/environments/prod/terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

### Deployment Steps

1. **Initialize Terraform**
   ```bash
   cd terraform/environments/prod
   terraform init
   ```

2. **Plan the Deployment**
   ```bash
   terraform plan -out=tfplan
   ```

3. **Apply the Configuration**
   ```bash
   terraform apply tfplan
   ```

4. **Configure kubectl**
   ```bash
   aws eks update-kubeconfig --name <cluster-name> --region <region>
   ```

## Testing Guide

### Infrastructure Testing

1. **Terraform Validation**
   ```bash
   # Validate Terraform configuration
   terraform validate

   # Check formatting
   terraform fmt -check -recursive
   ```

2. **Security Testing**
   ```bash
   # Run tfsec for security analysis
   tfsec .

   # Run checkov for compliance checking
   checkov -d .
   ```

3. **Cost Estimation**
   ```bash
   # Use infracost to estimate AWS costs
   infracost breakdown --path .
   ```

### Application Testing

1. **Local Testing**
   ```bash
   # Run the application stack locally
   docker-compose up --build

   # Run tests
   ./test.sh
   ```

2. **Load Testing**
   ```bash
   # Install k6
   brew install k6

   # Run load tests
   k6 run tests/performance/load-test.js
   ```

## Monitoring and Maintenance

### CloudWatch Dashboards
- EKS cluster metrics
- RDS performance metrics
- ALB request metrics
- WAF analytics

### Alerts and Notifications
- CPU/Memory utilization
- Database connections
- Error rates
- Cost thresholds

## Estimated Monthly Costs

| Component     | Estimated Cost |
|--------------|---------------|
| EKS          | $70-100      |
| RDS          | $50-60       |
| ElastiCache  | $30-40       |
| ALB          | $20-25       |
| WAF          | $10-15       |
| Other        | $20-30       |
| **Total**    | **$200-270** |

## Security Considerations

1. **Network Security**
   - Private subnets for workloads
   - Security groups with minimal access
   - WAF rules for application protection

2. **Data Security**
   - Encryption at rest for all services
   - TLS for data in transit
   - Secrets management via AWS Secrets Manager

3. **Access Control**
   - IAM roles with least privilege
   - RBAC for Kubernetes
   - Network policies for pod communication

## Troubleshooting Guide

1. **Common Issues**
   - EKS node scaling
   - Database connections
   - Load balancer health checks

2. **Logging**
   - Centralized logging with CloudWatch
   - ALB access logs in S3
   - WAF logs for security analysis

3. **Metrics**
   - Application metrics with Prometheus
   - Infrastructure metrics in CloudWatch
   - Custom dashboards for monitoring

## Backup and Disaster Recovery

1. **Automated Backups**
   - RDS daily backups
   - EFS backups for persistent volumes
   - S3 versioning for static files

2. **Recovery Procedures**
   - Database point-in-time recovery
   - Infrastructure recreation with Terraform
   - Application state restoration
