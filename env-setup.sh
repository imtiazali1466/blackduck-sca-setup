#!bin/bash

set -e

echo "Starting BlackDuck SCA installation on Amazon Ubuntu..."

# Update system
echo "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install essential packages
echo "Installing essential packages..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    jq \
    python3 \
    python3-pip \
    openjdk-11-jdk \
    maven \
    gradle \
    nodejs \
    npm \
    gnupg \
    apt-transport-https \
    ca-certificates \
    software-properties-common

# Install Docker
echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to Docker group
echo "Adding current user to docker group..."
sudo usermod -aG docker $USER

# Configure Docker daemon for production
echo "Configuring Docker daemon..."
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

# Start and enable Docker
echo "Starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Run hello-world image in the background
sudo su -l $USER -c "docker run hello-world"
sleep 3

# check Docker processes
echo "Checking Docker processes..."
sudo docker ps -a
sudo docker system prune -f # clean up

# Install additional security tools
echo "Installing security tools..."
sudo apt-get install -y fail2ban ufw

# Configure firewall
echo "Configuring firewall..."
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 8080/tcp # BlackDuck web UI
sudo ufw allow 9443/tcp # BlackDuck API
sudo ufw allow 5432/tcp # PostgreSQL
sudo ufw enable

echo "Installation completed successfully!"
echo "Please log out and log back in for group changes to take effect."
