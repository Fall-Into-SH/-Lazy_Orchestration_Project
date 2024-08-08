#!/bin/bash

# Container and image names
CONTAINER_NAME=mydns
IMAGE_NAME=alpine-dns

# Set DNS configuration directory variable
DNS_DIR=dns-config

# Stop the existing container if it's running
if [ $(docker ps -q -f name=$CONTAINER_NAME) ]; then
    echo "Stopping existing container..."
    docker stop $CONTAINER_NAME
    echo "Removing existing container..."
    docker rm $CONTAINER_NAME
fi

# Restart the container with the same settings
echo "Starting new container..."
docker run -d --name $CONTAINER_NAME \
  -p 53:53/udp -p 53:53/tcp \
  -v "$(pwd)/$DNS_DIR/etc/bind:/etc/bind" \
  -v "$(pwd)/$DNS_DIR/var/named:/var/named" \
  $IMAGE_NAME

echo "DNS server container has been restarted."

