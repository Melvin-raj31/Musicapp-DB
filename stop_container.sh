#!/bin/bash

echo "=== Stopping Musician App Container ==="

# Stop and remove existing container if running
if [ "$(docker ps -q -f name=musician-app)" ]; then
  echo "Stopping running musician-app container..."
  docker stop musician-app
  docker rm musician-app
  echo "Container stopped and removed."
else
  echo "No running musician-app container found. Skipping."
fi

# Clean up unused images to free disk space
echo "Pruning unused Docker images..."
docker image prune -f

echo "=== Cleanup complete ==="
