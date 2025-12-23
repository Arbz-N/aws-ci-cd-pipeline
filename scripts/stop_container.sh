#!/bin/bash
set -e

APP_NAME=<CONTAINER_NAME>

echo "Stopping old container if exists..."
docker stop $APP_NAME || true
docker rm $APP_NAME || true