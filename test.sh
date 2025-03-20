#!/bin/bash

# Exit on error
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🔍 Starting Docker configuration tests..."

# Test 1: Validate docker-compose files
echo "Testing docker-compose file syntax..."
docker-compose -f docker-compose.yml config > /dev/null
docker-compose -f docker-compose.test.yml config > /dev/null
echo -e "${GREEN}✓${NC} Docker Compose files are valid"

# Test 2: Build images
echo "Building Docker images..."
docker-compose build
docker-compose -f docker-compose.test.yml build
echo -e "${GREEN}✓${NC} Docker images built successfully"

# Test 3: Run application tests
echo "Running application tests..."
docker-compose -f docker-compose.test.yml up \
    --abort-on-container-exit \
    --exit-code-from test

# Test 4: Test production image
echo "Testing production image..."
docker build -t statuspage:test .
docker run --rm statuspage:test python -c "import django; print(f'Django {django.__version__} installed successfully')"
echo -e "${GREEN}✓${NC} Production image works correctly"

# Clean up
echo "Cleaning up..."
docker-compose -f docker-compose.test.yml down -v
docker rmi statuspage:test

echo -e "${GREEN}✓${NC} All tests completed successfully!"
