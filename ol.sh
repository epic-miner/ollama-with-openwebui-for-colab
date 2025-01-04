#!/bin/bash

# Install requirements
pip install -r requirements.txt

# Constants
WEBUI_USER="dockeruser"
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

# Function to install Docker
install_docker() {
    if command -v docker &>/dev/null; then
        print_message $YELLOW "Docker is already installed."
    else
        print_message $GREEN "Installing Docker..."
        curl -fsSL https://get.docker.com | sh
        if [ $? -ne 0 ]; then
            print_message $RED "Docker installation failed."
            exit 1
        fi
        print_message $GREEN "Docker installed successfully."
    fi
}

# Function to install Ollama
install_ollama() {
    if command -v ollama &>/dev/null; then
        print_message $YELLOW "Ollama is already installed."
    else
        print_message $GREEN "Installing Ollama..."
        curl -fsSL https://ollama.com/install.sh | sh
        if [ $? -ne 0 ]; then
            print_message $RED "Ollama installation failed."
            exit 1
        fi
        print_message $GREEN "Ollama installed successfully."
    fi
}

# Function to start Ollama serve
start_ollama_serve() {
    print_message $GREEN "Starting Ollama server..."
    ollama serve &
    sleep 5 # Give some time for Ollama server to start
    if ! curl --output /dev/null --silent --head --fail "$OLLAMA_URL"; then
        print_message $RED "Ollama server failed to start"
        exit 1
    else
        print_message $GREEN "Ollama server started successfully"
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

# Function to pull Docker image
pull_docker_image() {
    print_message $GREEN "Pulling Docker image $IMAGE_NAME..."
    docker pull $IMAGE_NAME
    if [ $? -ne 0 ]; then
        print_message $RED "Failed to pull Docker image"
        exit 1
    fi
    print_message $GREEN "Docker image pulled successfully"
}

# Function to start Docker container
start_container() {
    print_message $GREEN "Starting Docker container..."
    docker run -d \
        --name $CONTAINER_NAME \
        --env "OLLAMA_BASE_URL=$OLLAMA_URL" \
        --volume $DATA_DIR/data:/app/backend/data \
        --publish $HOST_PORT:$CONTAINER_PORT \
        $IMAGE_NAME
    if [ $? -ne 0 ]; then
        print_message $RED "Failed to start Docker container"
        exit 1
    fi
    print_message $GREEN "Docker container started successfully"
}

# Main execution flow
print_message $GREEN "Starting Open WebUI setup..."
check_root
install_docker
install_ollama
start_ollama_serve
create_user
setup_directories
pull_docker_image
start_container
print_message $GREEN "Setup complete! Open WebUI should be available at http://localhost:$HOST_PORT"
