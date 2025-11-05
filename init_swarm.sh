#!/bin/bash

set -e

echo "Initializing Docker Swarm..."

# Get current node IP
NODE_IP=$(hostname -I | awk '{print $1}')

# Initialize Docker Swarm
docker swarm init --advertise-addr $NODE_IP

# Create overlay network for BlackDuck
docker network create --driver overlay blackduck-net

# Create Docker secrets directory
mkdir -p /opt/blackduck/secrets

echo "Docker Swarm initialized successfully!"
echo "Manager token: $(docker swarm join-token manager -q)"
echo "Worker token: $(docker swarm join-token worker -q)"
