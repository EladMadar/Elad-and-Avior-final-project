# Status Page Infrastructure Project

A production-ready infrastructure setup for a Django-based status page application, optimized for cost-effectiveness and scalability on AWS.

## Application Overview

This project deploys a Django status page application that provides:
- Incident and maintenance management
- Real-time metrics and monitoring
- User and subscriber management
- External integrations (e.g., UptimeRobot)
- Two-factor authentication
- Markdown support for messages
- Custom plugin support

## Infrastructure as Code (Terraform)

### AWS Architecture ($200-270/month)

#### Network Layer
- **VPC Setup**
  - Multi-AZ architecture with public/private subnets
  - Single NAT Gateway for cost optimization
  - VPC endpoints for AWS services (S3, ECR)
  - Estimated cost: ~$30-40/month

#### Compute Layer
- **EKS Cluster**
  - SPOT instances (t3a.medium) for 60-70% cost savings
  - Auto-scaling configuration (1-5 nodes)
  - Cluster autoscaler enabled
  - Prometheus monitoring integration
  - Estimated cost: ~$70-100/month

#### Database Layer
- **RDS PostgreSQL**
  - ARM-based instance (db.t4g.medium)
  - Multi-AZ optional for production
  - Automated backups (7 days retention)
  - Performance Insights enabled
  - Estimated cost: ~$50-60/month

#### Caching Layer
- **ElastiCache Redis**
  - ARM-based instance (cache.t4g.medium)
  - Encryption at rest and in transit
  - Automatic failover (optional)
  - Estimated cost: ~$30-40/month

#### Security Layer
- **Application Load Balancer + WAF**
  - SSL/TLS termination
  - WAF rules and rate limiting
  - Access logs in S3
  - Estimated cost: ~$30-40/month

## Docker Configuration

### Development Setup
```bash
# Start development environment
docker-compose up --build

# Run tests
./test.sh
```

### Production Setup
```bash
# Build production image
docker build -t status-page:prod .

# Push to ECR
docker tag status-page:prod $ECR_REGISTRY/status-page:prod
docker push $ECR_REGISTRY/status-page:prod
```

### Container Components
- Python 3.11 slim Bullseye base image
- Gunicorn as WSGI server
- PostgreSQL 14
- Redis 7.0
- RQ worker for background tasks

## Quick Start

1. **Clone and Configure**
   ```bash
   git clone <repository-url>
   cd status-page
   ```

2. **Infrastructure Setup**
   ```bash
   cd terraform/environments/prod
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   
   # Test infrastructure
   ../test-infrastructure.sh
   
   # Deploy
   terraform init
   terraform apply
   ```

3. **Application Deployment**
   ```bash
   # Configure kubectl
   aws eks update-kubeconfig --name status-page-prod-cluster
   
   # Deploy application
   kubectl apply -f k8s/
   ```

## Testing

### Infrastructure Testing
```bash
# Validate Terraform configs
cd terraform
./test-infrastructure.sh

# Security checks
tfsec .

# Cost estimation
infracost breakdown --path .
```

### Application Testing
```bash
# Run test suite
./test.sh

# Run specific tests
docker-compose -f docker-compose.test.yml run --rm web pytest
```

## Documentation
- [Detailed Infrastructure Guide](INFRASTRUCTURE.md)
- [Cost Optimization Strategies](docs/cost-optimization.md)
- [Security Best Practices](docs/security.md)

## Contributing
1. Fork the repository
2. Create your feature branch
3. Run tests
4. Submit a pull request

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements
- Based on the Status-Page project
- Uses Tailwind UI components (requires license)
- Inspired by NetBox's architecture
