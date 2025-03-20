#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Starting infrastructure validation..."

# Function to check command existence
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 is required but not installed.${NC}"
        exit 1
    fi
}

# Check required tools
echo "Checking required tools..."
check_command "terraform"
check_command "aws"
check_command "jq"
echo -e "${GREEN}✓${NC} All required tools are installed"

# Validate AWS credentials
echo "Validating AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials are not configured correctly${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} AWS credentials are valid"

# Initialize Terraform
echo "Initializing Terraform..."
cd environments/prod
terraform init -backend=false

# Format check
echo "Checking Terraform formatting..."
if ! terraform fmt -check -recursive ../..; then
    echo -e "${YELLOW}⚠️  Terraform files need formatting${NC}"
    read -p "Would you like to format them now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform fmt -recursive ../..
        echo -e "${GREEN}✓${NC} Terraform files have been formatted"
    fi
else
    echo -e "${GREEN}✓${NC} Terraform formatting is correct"
fi

# Validate Terraform configuration
echo "Validating Terraform configuration..."
if ! terraform validate; then
    echo -e "${RED}❌ Terraform validation failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Terraform configuration is valid"

# Check for required variables
echo "Checking required variables..."
if [ ! -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}⚠️  terraform.tfvars file is missing${NC}"
    echo "Creating from example file..."
    cp terraform.tfvars.example terraform.tfvars
    echo -e "${YELLOW}⚠️  Please edit terraform.tfvars with your values${NC}"
fi

# Run cost estimation if infracost is installed
if command -v infracost &> /dev/null; then
    echo "Running cost estimation..."
    infracost breakdown --path . --format table
else
    echo -e "${YELLOW}⚠️  infracost not installed. Install it to see cost estimates:${NC}"
    echo "brew install infracost # on macOS"
    echo "infracost register     # get API key"
fi

# Run security checks if tfsec is installed
if command -v tfsec &> /dev/null; then
    echo "Running security checks..."
    tfsec ../..
else
    echo -e "${YELLOW}⚠️  tfsec not installed. Install it to run security checks:${NC}"
    echo "brew install tfsec # on macOS"
fi

# Generate plan
echo "Generating Terraform plan..."
if ! terraform plan -out=tfplan; then
    echo -e "${RED}❌ Terraform plan generation failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Terraform plan generated successfully"

echo -e "\n${GREEN}✅ Infrastructure validation completed!${NC}"
echo -e "\nNext steps:"
echo "1. Review the generated plan"
echo "2. Update terraform.tfvars with your values"
echo "3. Run 'terraform apply tfplan' to deploy"
echo -e "\n${YELLOW}Note: Estimated monthly cost should be under $300${NC}"
