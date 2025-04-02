# Status Page

A production-ready status page application deployed on AWS EKS with proper monitoring and observability.

## Architecture

- **Web Application**: Django-based status page with proper static file serving
- **Worker**: Background task processing via Django-RQ 
- **Infrastructure**: AWS EKS (Kubernetes) with proper scaling policies
  - 2 desired nodes (min: 1, max: 5) in us-east-1 region
- **Database**: PostgreSQL on AWS RDS
- **Caching/Queue**: Redis for task queueing
- **Monitoring**:
  - Prometheus for metrics collection
  - Grafana for metrics visualization and dashboards
  - Exporters for critical metrics (Node, PostgreSQL, Redis)
  - High-priority metrics: CPU usage, Memory usage, Load metrics

## Deployment

The application is deployed using Terraform with a modular infrastructure design:

```bash
# Initialize Terraform
cd terraform/environments/prod
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply
```

## Access

- **Status Page**: [https://status.elad-avior.com](https://status.elad-avior.com)
- **Grafana Dashboard**: [https://status.elad-avior.com/grafana](https://status.elad-avior.com/grafana)
  - Username: admin
  - Password: admin

## Infrastructure Components

| Component | Description | Module |
|-----------|-------------|--------|
| VPC | AWS VPC with public, private, and database subnets | `modules/vpc` |
| EKS | Kubernetes cluster for application deployment | `modules/eks` |
| RDS | PostgreSQL database for application data | `modules/rds` |
| Redis | In-memory database for caching and task queuing | `modules/redis` |
| ALB | Application Load Balancer for ingress traffic | `modules/alb` |
| WAF | Web Application Firewall for security | `modules/waf` |
| Kubernetes | Application deployments, services, and ingress | `modules/kubernetes` |

## Development

For local development:

```bash
# Start the application locally
docker-compose up
```

Access the local development environment at http://localhost:8000

## Monitoring

The application includes comprehensive monitoring with Prometheus and Grafana:

- **Server Metrics**: CPU usage, memory usage, load metrics (high priority)
- **Database Metrics**: Connection count, query performance, disk usage
- **Application Metrics**: Request rate, error rate, response time
- **Redis Metrics**: Memory usage, command executions, connected clients

## Maintaining

To update the application:

1. Make changes to the application code
2. Build and push new container images to ECR
3. Update Terraform configuration if needed
4. Apply changes with Terraform

## Troubleshooting

Common issues and solutions:

- **Missing CSS/Styling**: Static files are served via WhiteNoise middleware to ensure proper styling on all devices
- **Database Connectivity**: Check security groups and ensure RDS instance is running
- **Mobile Access Issues**: The application uses proper CORS headers and is configured for both IPv4 and IPv6 connectivity
