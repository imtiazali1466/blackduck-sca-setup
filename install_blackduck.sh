#!/bin/bash

set -e

echo "Deploying BlackDuck SCA..."

# Create directories
echo "Creating BlackDuck directories..."
sudo mkdir -p /opt/blackduck/{config,data,logs,secrets,backups}
sudo chown -R $USER:$USER /opt/blackduck

# Check if we're in swarm mode
if ! docker node ls &> /dev/null; then
    echo "Error: This node is not part of a Docker Swarm."
    echo "Please run ./init_swarm.sh first."
    exit 1
fi

# Create environment file
cat > /opt/blackduck/.env << EOF
# BlackDuck Configuration
BLACKDUCK_VERSION=2023.10.0
BLACKDUCK_CFG_HOSTNAME=$(hostname)
BLACKDUCK_CFG_PORT=8080
BLACKDUCK_CFG_SCHEME=http

# Database Configuration
POSTGRES_USER=blackduck
POSTGRES_PASSWORD=blackduck
POSTGRES_DB=blackduck
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

# Elasticsearch Configuration
ELASTICSEARCH_MEMORY=4g

# Application Settings
MAX_MEMORY=4096m
HUB_WEBSERVER_PORT=8080
HUB_WEBSERVER_SSL_PORT=8443
EOF

# Create Docker Compose file for Swarm
cat > /opt/blackduck/docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - blackduck_postgres_data:/var/lib/postgresql/data
    networks:
      - blackduck-net
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
    secrets:
      - postgres_password

  elasticsearch:
    image: docker.io/blackducksoftware/blackduck-elasticsearch:7.17.10
    environment:
      - "discovery.type=single-node"
      - "ES_JAVA_OPTS=-Xms${ELASTICSEARCH_MEMORY} -Xmx${ELASTICSEARCH_MEMORY}"
    volumes:
      - blackduck_es_data:/usr/share/elasticsearch/data
    networks:
      - blackduck-net
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure

  webapp:
    image: docker.io/blackducksoftware/hub-webapp:${BLACKDUCK_VERSION}
    environment:
      - HUB_WEBSERVER_HOST=${BLACKDUCK_CFG_HOSTNAME}
      - HUB_WEBSERVER_PORT=${HUB_WEBSERVER_PORT}
      - HUB_WEBSERVER_SSL_PORT=${HUB_WEBSERVER_SSL_PORT}
      - PUBLIC_HUB_WEBSERVER_HOST=${BLACKDUCK_CFG_HOSTNAME}
      - PUBLIC_HUB_WEBSERVER_PORT=${HUB_WEBSERVER_PORT}
    volumes:
      - blackduck_logs:/opt/blackduck/hub/logs
    networks:
      - blackduck-net
    ports:
      - "8080:8080"
      - "8443:8443"
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
    depends_on:
      - postgres
      - elasticsearch

  scan:
    image: docker.io/blackducksoftware/hub-scan:${BLACKDUCK_VERSION}
    environment:
      - HUB_WEBSERVER_HOST=webapp
    volumes:
      - blackduck_logs:/opt/blackduck/hub/logs
    networks:
      - blackduck-net
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
    depends_on:
      - webapp

  jobrunner:
    image: docker.io/blackducksoftware/hub-jobrunner:${BLACKDUCK_VERSION}
    environment:
      - HUB_WEBSERVER_HOST=webapp
    volumes:
      - blackduck_logs:/opt/blackduck/hub/logs
    networks:
      - blackduck-net
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
    depends_on:
      - webapp

secrets:
  postgres_password:
    external: true

volumes:
  blackduck_postgres_data:
    driver: local
  blackduck_es_data:
    driver: local
  blackduck_logs:
    driver: local

networks:
  blackduck-net:
    external: true
    name: blackduck-net
EOF

# Create PostgreSQL password secret
echo "blackduck" | docker secret create postgres_password -

# Deploy the stack
cd /opt/blackduck
docker stack deploy -c docker-compose.yml blackduck

echo "BlackDuck deployment started!"
echo "Check status with: docker service ls"
echo "View logs with: docker service logs blackduck_webapp"
