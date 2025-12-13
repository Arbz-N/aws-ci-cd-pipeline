#!/bin/bash

set -e
echo "image is pulling"
docker pull arbaznaeem/simple-python-flask-app

docker run -d -p 5000:5000 arbaznaeem/simple-python-flask-app 
