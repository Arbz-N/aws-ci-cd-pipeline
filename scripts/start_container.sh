#!/bin/bash

set -e

docker pull docker pull arbaznaeem/simple-python-flask-app

docker run -d -p 5000:5000 arbaznaeem/simple-python-flask-app