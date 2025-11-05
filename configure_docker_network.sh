#!/bin/bash

set -e

echo "Configuring Docker daemon with custom network settings..."

DOCKER_DAEMON_JSON="/etc/docker/daemon.json"

# Backup existing configuration
if [ -f "$DOCKER_DAEMON_JSON" ]; then
    sudo cp "$DOCKER_DAEMON_JSON" "${DOCKER_DAEMON_JSON}.bak.$(date +%Y%m%d_%H%M%S)"
    echo "Existing configuration backed up."
fi

# Create new daemon.json
sudo tee "$DOCKER_DAEMON_JSON" > /dev/null <<'EOF'
{
  "bip": "172.30.0.1/16",
  "default-address-pools": [
    {
      "base": "172.30.0.0/16",
      "size": 24
    }
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "live-restore": true,
  "mtu": 1450
}
EOF

# Restart Docker daemon
echo "Restarting Docker daemon..."
sudo systemctl restart docker

# Wait for Docker to be ready
sleep 10

# Verify configuration
echo "Verifying Docker network configuration..."
docker info | grep -A 10 "Default Address Pools"

echo "Docker network configuration completed successfully!"
