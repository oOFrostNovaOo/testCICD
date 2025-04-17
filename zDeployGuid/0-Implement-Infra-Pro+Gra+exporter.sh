#!/bin/bash

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running. Please start Docker and try again."
    exit 1
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

docker stack deploy -c ../prometheus/docker-compose.yml Infra_stack
docker stack deploy -c ../node-exporter/node-exporter.yml Infra_stack
docker stack deploy -c ../grafana/docker-compose.yml  Infra_stack


echo "Infrastructure has been deployed."
