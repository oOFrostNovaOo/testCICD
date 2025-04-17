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
if ! docker network ls | grep -q "Infra_stack"; then
    echo "Creating overlay network 'Infra_stack'..."
    docker network create --driver overlay Infra_stack
else
    echo "Overlay network 'Infra_stack' already exists."
fi

#docker build custom/jenkins image
docker build -t custom/img-jenk-ans-ter -f ../jenkins/dockerfile .

# Add insecure registry to Docker daemon configuration
# Check if the Docker daemon configuration file exists
sudo jq '. + { "insecure-registries": ["192.168.1.201:5000"] }' /etc/docker/daemon.json | sudo tee /etc/docker/daemon.json.new && \
sudo mv /etc/docker/daemon.json.new /etc/docker/daemon.json && \
sudo systemctl restart docker


docker stack deploy -c ../jenkins/docker-compose.yml Infra_stack
docker stack deploy -c ../registry/docker-compose.yml Infra_stack

echo "CICD stack has been deployed."
