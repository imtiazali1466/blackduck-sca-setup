#!/bin/bash

set -e

echo "Installing BlackDuck SCA using official method..."

# Create installation directory
sudo mkdir -p /opt/blackduck
cd /opt/blackduck

# Download and run the official BlackDuck install script
echo "Downloading BlackDuck installation script..."
curl -s https://blackducksoftware.github.io/hub-download/hub-download.sh | bash

# The script will:
# 1. Download the latest docker-compose.yml
# 2. Download all required Docker images
# 3. Create necessary directories
# 4. Generate default configuration

echo "Official BlackDuck installation completed!"
echo "Docker-compose.yml and images downloaded successfully."
