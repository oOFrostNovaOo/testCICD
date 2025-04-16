#!/bin/bash

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Create a Docker Swarm if not already initialized
if ! docker info | grep -q "Swarm: active"; then
    echo "Initializing Docker Swarm..."
    docker swarm init
fi

# Deploy the Docker Compose stack
echo "Deploying the Docker Compose stack..."
# Check if the overlay network already exists
if ! docker network ls | grep -q "cicd_stack"; then
    echo "Creating overlay network 'cicd_stack'..."
    docker network create --driver overlay cicd_stack
else
    echo "Overlay network 'cicd_stack' already exists."
fi

#docker build custom/jenkins image
docker build -t custom/img-jenk-ans-ter -f ../jenkins/dockerfile .

docker stack deploy -c ../jenkins/docker-compose.yml cicd_stack
docker stack deploy -c ../registry/docker-compose.yml cicd_stack

echo "CICD stack has been deployed."
