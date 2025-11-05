#!/bin/bash

# BlackDuck Management Commands

case "$1" in
    status)
        echo "=== BlackDuck Services Status ==="
        docker service ls | grep blackduck
        ;;
    logs)
        echo "=== BlackDuck Logs ==="
        docker service logs blackduck_${2:-webapp} --tail 50 -f
        ;;
    restart)
        echo "Restarting BlackDuck services..."
        docker service update --force blackduck_${2:-webapp}
        ;;
    scale)
        echo "Scaling service..."
        docker service scale blackduck_${2}=${3}
        ;;
    backup)
        echo "Starting backup..."
        BACKUP_DIR="/opt/blackduck/backups/$(date +%Y%m%d_%H%M%S)"
        mkdir -p $BACKUP_DIR
        
        # Backup PostgreSQL
        docker exec $(docker ps -q -f name=blackduck_postgres) pg_dump -U blackduck blackduck > $BACKUP_DIR/blackduck_db.sql
        
        # Backup configuration
        cp -r /opt/blackduck/config $BACKUP_DIR/
        
        echo "Backup completed: $BACKUP_DIR"
        ;;
    update)
        echo "Updating BlackDuck..."
        cd /opt/blackduck
        docker stack deploy -c docker-compose.yml blackduck
        ;;
    *)
        echo "Usage: $0 {status|logs [service]|restart [service]|scale service count|backup|update}"
        echo "Available services: webapp, scan, jobrunner, postgres, elasticsearch"
        exit 1
esac
