#!/bin/bash
set -e

APP_NAME=flask-app
IMAGE=arbaznaeem/simple-python-flask-app
PORT=5000

echo "Pulling latest image..."
docker pull $IMAGE

echo "Starting new container..."
docker run -d --name $APP_NAME -p $PORT:$PORT $IMAGE
