# blackduck-sca-setup
Script for setting up Balckduck SCA service using docker images and swarm
# BlackDuck SCA Installation on Amazon Ubuntu with Docker Swarm

## Overview
This documentation provides instructions for installing and configuring BlackDuck Software Composition Analysis (SCA) tool on Amazon Ubuntu server using Docker Swarm.

## Prerequisites
- Amazon Ubuntu 20.04 LTS or 22.04 LTS
- Minimum 8GB RAM (16GB recommended)
- 100GB free disk space
- Docker and Docker Swarm installed
- BlackDuck license files

## Architecture
- BlackDuck runs as a Docker Swarm service
- Uses PostgreSQL database
- Redis for caching
- Elasticsearch for search functionality

## Directory Structure
/opt/blackduck/
├── config/
├── data/
├── logs/
├── secrets/
└── docker-compose.yml

## Quick Start
1. Run the installation script: `./install_blackduck.sh`
2. Initialize Docker Swarm: `./init_swarm.sh`
3. Deploy BlackDuck: `./deploy_blackduck.sh`
