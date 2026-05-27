#!/bin/bash

# n8n Workflow Backup Script
# Backs up n8n workflows to local directory with timestamp

set -e

# Configuration
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/workflows_backup_${TIMESTAMP}.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting n8n workflow backup...${NC}"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Check if n8n container is running
if ! docker ps | grep -q n8n; then
    echo -e "${RED}Error: n8n container is not running${NC}"
    echo "Start it with: docker-compose up -d"
    exit 1
fi

# Copy workflows from container
echo "Copying workflows from n8n container..."
docker cp n8n:/home/node/.n8n/workflows "$BACKUP_DIR/temp_workflows" 2>/dev/null || {
    echo -e "${RED}Error: Failed to copy workflows from container${NC}"
    echo "Make sure workflows exist in the container"
    exit 1
}

# Create compressed archive
if [ -d "$BACKUP_DIR/temp_workflows" ]; then
    echo "Creating backup archive..."
    tar -czf "${BACKUP_FILE}.tar.gz" -C "$BACKUP_DIR" temp_workflows
    
    # Cleanup temp directory
    rm -rf "$BACKUP_DIR/temp_workflows"
    
    # Get file size
    SIZE=$(du -h "${BACKUP_FILE}.tar.gz" | cut -f1)
    
    echo -e "${GREEN}✅ Backup completed successfully!${NC}"
    echo -e "Location: ${BACKUP_FILE}.tar.gz"
    echo -e "Size: $SIZE"
    
    # Keep only last 10 backups
    BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/workflows_backup_*.tar.gz 2>/dev/null | wc -l)
    if [ "$BACKUP_COUNT" -gt 10 ]; then
        echo "Cleaning up old backups (keeping last 10)..."
        ls -t "$BACKUP_DIR"/workflows_backup_*.tar.gz | tail -n +11 | xargs rm -f
    fi
    
    echo -e "${GREEN}Backup process complete!${NC}"
else
    echo -e "${RED}Error: No workflows found${NC}"
    exit 1
fi

# Optional: Show backup list
echo ""
echo "Available backups:"
ls -lh "$BACKUP_DIR"/workflows_backup_*.tar.gz 2>/dev/null || echo "No backups found"
