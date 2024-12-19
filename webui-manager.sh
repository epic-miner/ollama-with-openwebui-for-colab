#!/bin/bash

# Constants
WEBUI_USER="udockeruser"
DATA_DIR="/content/open-webui"
IMAGE_NAME="ghcr.io/open-webui/open-webui:main"
CONTAINER_NAME="open-webui"
HOST_PORT="3000"
CONTAINER_PORT="8080"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_message $RED "Please run as root"
        exit 1
    fi
}

# Function to create user
create_user() {
    if id "$WEBUI_USER" &>/dev/null; then
        print_message $YELLOW "User $WEBUI_USER already exists"
    else
        print_message $GREEN "Creating user $WEBUI_USER"
        adduser --disabled-password --gecos "" $WEBUI_USER
        print_message $GREEN "User created successfully"
    fi
}

# Function to setup directories
setup_directories() {
    print_message $GREEN "Setting up directories..."
    mkdir -p $DATA_DIR/data
    chown -R $WEBUI_USER:$WEBUI_USER $DATA_DIR
    chmod -R 755 $DATA_DIR
    print_message $GREEN "Directories setup complete"
}

# Function to setup container as udockeruser
setup_container() {
    print_message $GREEN "Setting up container as $WEBUI_USER..."
    su - $WEBUI_USER -c "
        udocker pull $IMAGE_NAME && \
        udocker create --name=$CONTAINER_NAME $IMAGE_NAME
    "
    print_message $GREEN "Container setup complete"
}

# Function to start container
start_container() {
    local ollama_url=$1
    print_message $GREEN "Starting container..."
    su - $WEBUI_USER -c "
        udocker run \
        --env=\"OLLAMA_BASE_URL=$ollama_url\" \
        --volume=$DATA_DIR/data:/app/backend/data \
        --publish=$HOST_PORT:$CONTAINER_PORT \
        $CONTAINER_NAME
    "
}

# Function to backup data
backup_data() {
    local backup_name="webui-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    print_message $GREEN "Creating backup: $backup_name"
    tar -czf "$backup_name" $DATA_DIR/data
    chown $WEBUI_USER:$WEBUI_USER "$backup_name"
    print_message $GREEN "Backup created successfully"
}

# Function to restore backup
restore_backup() {
    local backup_file=$1
    if [ ! -f "$backup_file" ]; then
        print_message $RED "Backup file not found: $backup_file"
        return 1
    fi
    print_message $GREEN "Restoring from backup: $backup_file"
    tar -xzf "$backup_file" -C $DATA_DIR
    chown -R $WEBUI_USER:$WEBUI_USER $DATA_DIR
    print_message $GREEN "Restore completed"
}

# Function to update container
update_container() {
    print_message $GREEN "Updating container..."
    su - $WEBUI_USER -c "
        udocker pull $IMAGE_NAME && \
        udocker rm $CONTAINER_NAME && \
        udocker create --name=$CONTAINER_NAME $IMAGE_NAME
    "
    print_message $GREEN "Update complete"
}

# Help function
show_help() {
    cat << EOF
Usage: $0 [command] [options]

Commands:
    setup <ollama_url>     - Initial setup and start (requires ollama_url)
    start <ollama_url>     - Start existing container
    backup                 - Create backup
    restore <backup_file>  - Restore from backup
    update                 - Update container
    help                   - Show this help

Examples:
    $0 setup http://localhost:11434
    $0 start http://localhost:11434
    $0 backup
    $0 restore webui-backup.tar.gz
    $0 update
EOF
}

# Main script execution
case "$1" in
    setup)
        if [ -z "$2" ]; then
            print_message $RED "Error: Ollama URL required"
            show_help
            exit 1
        fi
        check_root
        create_user
        setup_directories
        setup_container
        start_container "$2"
        ;;
    start)
        if [ -z "$2" ]; then
            print_message $RED "Error: Ollama URL required"
            show_help
            exit 1
        fi
        check_root
        start_container "$2"
        ;;
    backup)
        check_root
        backup_data
        ;;
    restore)
        if [ -z "$2" ]; then
            print_message $RED "Error: Backup file required"
            show_help
            exit 1
        fi
        check_root
        restore_backup "$2"
        ;;
    update)
        check_root
        update_container
        ;;
    help|*)
        show_help
        ;;
esac
