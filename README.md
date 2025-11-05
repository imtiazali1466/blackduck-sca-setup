# 🛡️ BlackDuck SCA Installation on Amazon Ubuntu with Docker Swarm

This documentation provides comprehensive instructions for installing and configuring **BlackDuck Software Composition Analysis (SCA)** on an **Amazon Ubuntu** server using **Docker Swarm** with a custom, secure network configuration.

---

## 🎯 Overview

BlackDuck is deployed as a Docker Swarm stack with segregated networks for enhanced security.

* **Platform:** Amazon Ubuntu (20.04 LTS or 22.04 LTS)
* **Containerization:** Docker and Docker Swarm
* **Components:** BlackDuck services, PostgreSQL, Elasticsearch, NGiNX (for SSL termination)
* **Security:** Custom Docker networks and directory segregation.

---

## ⚙️ Prerequisites

| Requirement | Specification | Notes |
| :--- | :--- | :--- |
| **Operating System** | Amazon Ubuntu 20.04 LTS or 22.04 LTS | |
| **Memory (RAM)** | Minimum **8GB** (16GB recommended) | |
| **Storage** | **100GB** free disk space | For data and logs. |
| **Platform** | Docker and Docker Swarm installed | |
| **Licensing** | Valid BlackDuck license files | Essential for deployment. |

---

## 📂 Directory Structure

The installation uses a standard structure under `/opt/blackduck/`.

/opt/blackduck/
├── config/
│   └── nginx.conf            # NGiNX Reverse Proxy config
├── data/
│   ├── postgres/            # PostgreSQL data volume
│   └── elasticsearch/       # Elasticsearch data volume
├── logs/                     # Application and Swarm logs
├── backups/                  # Database backups
├── secrets/
│   └── ssl/                  # SSL Certificates
├── docker-compose.yml        # Docker Swarm stack definition
└── .env                      # Environment variables (credentials, versions)

Essential Paths and Directories
bash
# Main installation directory
/opt/blackduck/

# Configuration files
/opt/blackduck/config/

# Data directories
/opt/blackduck/data/
/opt/blackduck/data/postgres/      # PostgreSQL data
/opt/blackduck/data/elasticsearch/ # Elasticsearch data

# Log files
/opt/blackduck/logs/

# Backup directory
/opt/blackduck/backups/

# Docker Compose file
/opt/blackduck/docker-compose.yml

# Environment variables
/opt/blackduck/.env
Quick Start
1. System Preparation
bash
# Make scripts executable
chmod +x *.sh

# Install essential packages and runtimes
./install_blackduck.sh

# Configure Docker network (requires logout/login after Docker group changes)
sudo ./configure_docker_network.sh
2. Docker Swarm Setup
bash
# Initialize Docker Swarm with custom networks
./init_swarm_advanced.sh
3. BlackDuck Deployment
bash
# Deploy BlackDuck stack
./deploy_blackduck.sh

# Verify deployment
./health_check.sh
Network Configuration
The installation uses custom Docker network configuration for enhanced security and performance:

Bridge IP: 172.30.0.1/16

Default Address Pool: 172.30.0.0/16 with /24 subnets

Segregated Networks:

blackduck-frontend (172.30.1.0/24) - Public facing services

blackduck-backend (172.30.2.0/24) - Internal services

blackduck-database (172.30.3.0/24) - Database services

Common Operations
Start all services:
bash
cd /opt/blackduck
docker stack deploy -c docker-compose.yml blackduck
Stop all services:
bash
docker stack rm blackduck
View logs:
bash
docker service logs blackduck_webapp -f
Scale services:
bash
docker service scale blackduck_scan=3
Backup database:
bash
./blackduck_commands.sh backup
Check service status:
bash
./blackduck_commands.sh status
Restart services:
bash
./blackduck_commands.sh restart webapp
Security Considerations
Change default passwords in the environment file immediately after installation

Enable SSL/TLS with valid certificates for production environments

Configure firewall to restrict access to essential ports only

Regular backups of PostgreSQL data and configuration files

Monitor resource usage and scale services accordingly

Use encrypted overlay networks for swarm communication

Restrict database port access to trusted IP ranges only

Firewall Configuration
bash
# Essential ports to open
sudo ufw allow 22/tcp                    # SSH
sudo ufw allow 443/tcp                   # HTTPS Web UI
sudo ufw allow 55436/tcp                 # PostgreSQL reporting
sudo ufw allow from 10.0.0.0/8 to any port 55436  # Restrict DB access

# Docker Swarm ports
sudo ufw allow 2377/tcp                  # Swarm management
sudo ufw allow 7946/tcp                  # Swarm node communication  
sudo ufw allow 7946/udp
sudo ufw allow 4789/udp                  # Overlay network traffic
Runtime Dependencies
BlackDuck requires these runtimes for comprehensive code analysis:

Python3 & pip: Python dependency analysis and virtual environment parsing

Java JDK 11: Java bytecode analysis and compilation

Maven & Gradle: Java build system dependency resolution

Node.js & npm: JavaScript/TypeScript package analysis

Additional Tools: curl, wget, git, jq for various operations

Troubleshooting
Check service status:
bash
docker service ls
View detailed logs:
bash
docker service logs blackduck_webapp
Verify network:
bash
docker network ls | grep blackduck
Check resource usage:
bash
docker stats
Verify network configuration:
bash
./check_networks.sh
Check container connectivity:
bash
docker exec <container_id> nslookup webapp
Test service health:
bash
curl -f http://localhost:8080/api/health-checks/status
Backup and Recovery
Automated Backups
bash
# Manual backup
./blackduck_commands.sh backup

# Schedule daily backups (add to crontab)
0 2 * * * /opt/blackduck/blackduck_commands.sh backup
Backup Contents
PostgreSQL database dump

Configuration files

SSL certificates

Environment variables

Application settings

Monitoring and Maintenance
Health Checks
bash
# Run comprehensive health check
./health_check.sh

# Check individual services
docker service ps blackduck_webapp

# Verify all services are running
docker service ls | grep blackduck
Log Management
Log Location: /opt/blackduck/logs/

Docker Log Rotation: 100MB max size, 3 files retained

Application Logs: Access via docker service logs <service_name>

System Logs: Monitor with journalctl -u docker.service

Performance Monitoring
bash
# Real-time resource usage
docker stats

# Service replica status
docker service ls

# Network traffic monitoring
docker network inspect blackduck-frontend

# Disk space monitoring
df -h /opt/blackduck
Scripts Overview
Script	Purpose
install_blackduck.sh	Installs system dependencies and language runtimes
configure_docker_network.sh	Configures Docker daemon with custom network settings
init_swarm_advanced.sh	Initializes Docker Swarm with segregated networks
deploy_blackduck.sh	Deploys BlackDuck stack with proper configuration
blackduck_commands.sh	Management commands for daily operations
health_check.sh	Comprehensive system and service health verification
check_networks.sh	Network configuration and connectivity verification
Docker Network Architecture
The installation implements a three-tier network architecture:

Frontend Network (172.30.1.0/24): Public-facing services (NGiNX)

Backend Network (172.30.2.0/24): Internal application services

Database Network (172.30.3.0/24): Isolated database services

This segregation enhances security by limiting exposure and controlling service communication.

Support and Troubleshooting
For issues with this installation:

Check Prerequisites: Verify all system requirements are met

Review Logs: Use docker service logs for detailed error information

Network Verification: Run ./check_networks.sh to validate network configuration

Health Check: Execute ./health_check.sh for comprehensive system status

Resource Monitoring: Check system resources with docker stats and df -h

Common issues and solutions:

Port conflicts: Verify no other services are using ports 443 or 55436

Network issues: Ensure Docker Swarm is properly initialized and networks created

Resource exhaustion: Monitor memory and disk usage, scale services if needed

SSL errors: Verify certificate paths and permissions in NGiNX configuration

License
This installation script is provided as-is for educational and implementation purposes. Please ensure you have proper BlackDuck licenses before deployment in production environments.

Make Scripts Executable
bash
# Make all scripts executable
chmod +x *.sh

# Verify executable permissions
ls -la *.sh
This comprehensive documentation provides complete guidance for setting up, operating, and maintaining BlackDuck SCA in a Docker Swarm environment with enterprise-grade network security and monitoring capabilities.

