#!/bin/bash

#install requirements
pip install -r requirements.txt

# Constants
WEBUI_USER="udockeruser"
DATA_DIR="/content/open-webui"
IMAGE_NAME="ghcr.io/open-webui/open-webui:main"
CONTAINER_NAME="open-webui"
HOST_PORT="3000"
CONTAINER_PORT="8080"
OLLAMA_URL="http://127.0.0.1:11434"  # Default Ollama URL

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
    print_message $GREEN "Starting container..."
    su - $WEBUI_USER -c "
        udocker run \
        --env=\"OLLAMA_BASE_URL=$OLLAMA_URL\" \
        --volume=$DATA_DIR/data:/app/backend/data \
        --publish=$HOST_PORT:$CONTAINER_PORT \
        $CONTAINER_NAME
    "
}

print_message $GREEN "Starting Open WebUI setup..."
check_root
create_user
setup_directories
setup_container
start_container
print_message $GREEN "Setup complete! Open WebUI should be available at http://localhost:3000"
