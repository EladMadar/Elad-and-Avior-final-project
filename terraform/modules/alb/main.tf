# ALB Module - Creates Application Load Balancer with optimal settings for cost and performance

locals {
  name = "${var.project}-${var.environment}-alb"
}

# ALB Security Group
resource "aws_security_group" "alb" {
  name_prefix = "${local.name}-sg-"
  vpc_id      = var.vpc_id

  # Allow inbound HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound HTTPS traffic
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name}-sg"
  })
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = local.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets           = var.public_subnet_ids

  # Enable deletion protection in production
  enable_deletion_protection = var.environment == "prod"

  # Enable access logs with 7-day retention for troubleshooting
  access_logs {
    bucket  = aws_s3_bucket.logs.id
    prefix  = "alb-logs"
    enabled = true
  }

  tags = var.tags
}

# S3 bucket for ALB access logs
resource "aws_s3_bucket" "logs" {
  bucket_prefix = "${local.name}-logs-"
  force_destroy = var.environment != "prod"

  tags = var.tags
}

# S3 bucket versioning for logs
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket lifecycle rules for cost optimization
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "cleanup-old-logs"
    status = "Enabled"

    filter {
      prefix = "alb-logs/"
    }

    expiration {
      days = var.log_retention_days
    }
  }
}

# ALB Listener for HTTPS (only created if certificate is provided)
resource "aws_lb_listener" "https" {
  count = var.certificate_arn != null ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# ALB Listener for HTTP
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = var.certificate_arn != null ? "redirect" : "forward"
    dynamic "redirect" {
      for_each = var.certificate_arn != null ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    dynamic "forward" {
      for_each = var.certificate_arn == null ? [1] : []
      content {
        target_group {
          arn = aws_lb_target_group.main.arn
        }
      }
    }
  }
}

# Target Group for EKS
resource "aws_lb_target_group" "main" {
  name        = "${local.name}-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval           = 15
    matcher            = "200"
    path               = "/health/"
    port               = "traffic-port"
    timeout            = 5
    unhealthy_threshold = 3
  }

  tags = var.tags
}

# Associate WAF with ALB
resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = var.waf_acl_arn
}
