#!/bin/bash

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unsupported"
    fi
}

# Function to check if Ollama is already installed
check_ollama() {
    if command -v ollama >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to install Ollama on Linux
install_linux() {
    echo "Installing Ollama on Linux..."
    curl -fsSL https://ollama.com/install.sh | sh
}

# Function to install Ollama on macOS
install_macos() {
    echo "Installing Ollama on macOS..."
    if command -v brew >/dev/null 2>&1; then
        brew install ollama
    else
        echo "Homebrew is not installed. Please install Homebrew first:"
        echo "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
}

# Function to get local IP address
get_local_ip() {
    if [[ "$(detect_os)" == "linux" ]]; then
        ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | cut -d/ -f1 | head -n 1
    else
        ipconfig getifaddr en0 || ipconfig getifaddr en1
    fi
}

# Function to install and setup Open WebUI
setup_webui() {
    echo "Installing Open WebUI..."
    
    # Download the setup script
    curl -O https://raw.githubusercontent.com/open-webui/open-webui/main/open-webui-setup.sh
    
    # Make it executable
    chmod +x open-webui-setup.sh
    
    # Get local IP for Ollama URL
    LOCAL_IP=$(get_local_ip)
    
    # Run the setup script
    ./open-webui-setup.sh setup "http://${LOCAL_IP}:11434"
}

# Main installation script
main() {
    echo "Starting Ollama installation..."
    
    # Check if already installed
    if check_ollama; then
        echo "Ollama is already installed!"
    else
        # Detect OS and install accordingly
        OS=$(detect_os)
        case $OS in
            "linux")
                install_linux
                ;;
            "macos")
                install_macos
                ;;
            *)
                echo "Unsupported operating system"
                exit 1
                ;;
        esac
    fi

    # Verify installation
    if ! check_ollama; then
        echo "Installation failed!"
        exit 1
    fi

    echo "Installation successful!"
    
    # Start Ollama service
    echo "Starting Ollama service..."
    if [[ "$(detect_os)" == "linux" ]]; then
        sudo systemctl start ollama
    else
        ollama serve &
    fi
    
    # Pull and run a test model
    echo "Pulling the default model (this may take a while)..."
    ollama pull llama2
    
    echo "Testing Ollama with a simple prompt..."
    ollama run llama2 "Say hello!"
    
    # Setup Open WebUI
    echo "Setting up Open WebUI..."
    setup_webui
    
    echo "Installation and setup complete! Open WebUI should now be available."
}

# Run the script
main
