#!/usr/bin/env bash

set -e

# Build the project and docker images
#mvn clean install
#mvn install

# Export the active docker machine IP
export DOCKER_IP=$(docker-machine ip $(docker-machine active))

# docker-machine doesn't exist in Linux, assign default ip if it's not set
DOCKER_IP=${DOCKER_IP:-0.0.0.0}

# Remove existing containers
docker-compose stop
docker-compose rm -f

# Start the discovery service first and wait for it to become available
docker-compose up -d discovery-service

while [ -z ${DISCOVERY_SERVICE_READY} ]; do
  echo "Waiting for discovery service..."
  if [ "$(curl --silent $DOCKER_IP:8081/health 2>&1 | grep -q '\"status\":\"UP\"'; echo $?)" = 0 ]; then
      DISCOVERY_SERVICE_READY=true;
  fi
  sleep 2
done

# Start the other containers
#docker-compose up -d

# Attach to the log output of the cluster
docker-compose logs
