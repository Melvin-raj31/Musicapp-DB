#!/bin/bash
set -e

echo "=== Starting Musician App Container ==="

# Pull latest image from ECR
echo "Pulling latest Docker image..."
docker pull $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:latest

# Run the container with RDS environment variables
# These are injected by ECS Task Definition (not hardcoded here!)
echo "Starting musician-app container..."
docker run -d \
  --name musician-app \
  --restart unless-stopped \
  -p 5000:5000 \
  -e DB_HOST=$DB_HOST \
  -e DB_USER=$DB_USER \
  -e DB_PASSWORD=$DB_PASSWORD \
  -e DB_NAME=$DB_NAME \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:latest

echo "=== Container started successfully! ==="
docker ps | grep musician-app
