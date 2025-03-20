# VPC Module - Creates a VPC with public and private subnets across 3 AZs

# Get available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Calculate subnet CIDRs based on VPC CIDR
  public_subnets  = [for i in range(3) : cidrsubnet(var.vpc_cidr, 4, i)]
  private_subnets = [for i in range(3) : cidrsubnet(var.vpc_cidr, 4, i + 3)]
  database_subnets = [for i in range(3) : cidrsubnet(var.vpc_cidr, 4, i + 6)]
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-igw"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.public_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                                          = "${var.project}-${var.environment}-public-${count.index + 1}"
    "kubernetes.io/role/elb"                      = 1
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
  })
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.tags, {
    Name                                          = "${var.project}-${var.environment}-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb"             = 1
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
  })
}

# Database Subnets
resource "aws_subnet" "database" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.database_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-db-${count.index + 1}"
  })
}

# NAT Gateways with Elastic IPs
resource "aws_eip" "nat" {
  count = 1  # Using single NAT Gateway for cost optimization
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-nat-${count.index + 1}"
  })
}

resource "aws_nat_gateway" "main" {
  count         = 1
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-public-rt"
  })
}

resource "aws_route_table" "private" {
  count  = 3
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-private-rt-${count.index + 1}"
  })
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# VPC Endpoints for cost optimization
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  
  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-s3-endpoint"
  })
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  private_dns_enabled = true
  
  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-ecr-api-endpoint"
  })
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  private_dns_enabled = true
  
  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-ecr-dkr-endpoint"
  })
}

# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.project}-${var.environment}-vpc-endpoints-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  
  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-vpc-endpoints-sg"
  })
}
