#!/bin/bash
set -e

APP_NAME=<CONTAINER_NAME>
IMAGE=<DOCKER_IMAGE>
PORT=<PORT_NUMBER>

echo "Pulling latest image..."
docker pull $IMAGE

echo "Starting new container..."
docker run -d --name $APP_NAME -p $PORT:$PORT $IMAGE

