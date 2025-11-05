#!/bin/bash

echo "=== BlackDuck Health Check ==="

# Check Docker services
echo "1. Checking Docker services..."
docker service ls | grep blackduck

# Check container status
echo -e "\n2. Checking container status..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep blackduck

# Check service connectivity
echo -e "\n3. Checking service connectivity..."
curl -f http://localhost:8080/api/health-checks/status > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ BlackDuck webapp is responding"
else
    echo "❌ BlackDuck webapp is not responding"
fi

# Check disk space
echo -e "\n4. Checking disk space..."
df -h /opt/blackduck

# Check memory usage
echo -e "\n5. Checking memory usage..."
free -h

# Check recent logs for errors
echo -e "\n6. Checking for recent errors..."
docker service logs blackduck_webapp --tail 20 | grep -i error

echo -e "\nHealth check completed!"
