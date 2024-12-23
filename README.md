# Open WebUI Setup Script with Ollama Integration

This script automates the setup of Open WebUI, a user-friendly interface for interacting with language models, along with the installation and startup of Ollama, a local large language model server. It uses `udocker` to manage the Open WebUI container.

## Prerequisites

*   **Linux Operating System:** This script is designed for Linux-based systems.
*   **Root Privileges:** The script requires root privileges to create users, manage directories, and install software.
*   **`udocker` Installed:** Make sure `udocker` is installed on your system. You can install it using `pip install udocker`.
*   **`pip` Installed:** Python's package installer `pip` is required.

## Script Functionality

The script performs the following actions:

1.  **Installs Python dependencies:** Installs the python dependencies in the `requirements.txt` file.
2.  **Installs Ollama:** Downloads and installs the Ollama server if it's not already present. **Note:** The script uses `curl -fsSL https://ollama.com/install.sh | sh` to install Ollama. While this is a convenient method, it is important to be aware of the security implications of piping the output of `curl` directly to `sh`. For enhanced security, consider downloading the Ollama binary directly from the [official Ollama website](https://ollama.com) and running it manually.
3.  **Starts Ollama Server:** Starts the Ollama server in the background and verifies that it's running.
4.  **Creates a Dedicated User:** Creates a user named `udockeruser` to run the Open WebUI container, enhancing security.
5.  **Sets up Directories:** Creates the necessary data directories for Open WebUI and sets the correct permissions.
6.  **Pulls and Creates the Open WebUI Container:** Downloads the Open WebUI container image and creates a container using `udocker`.
7.  **Starts the Open WebUI Container:** Runs the Open WebUI container with the necessary environment variables, volume mounts, and port mappings.

## Usage

### Google Colab

1.  Open a new Google Colab notebook.
2.  Copy and paste the content of the `setup_openwebui.sh` script into a code cell.
3.  Run the code cell using `!bash ./setup_openwebui.sh`.
4.  Once the script completes successfully, Open WebUI should be accessible in your web browser at:
    ```
    http://localhost:3000
    ```

### Other Linux Systems

1.  Save the provided script to a file, for example, `setup_openwebui.sh`.
2.  Make the script executable: `chmod +x setup_openwebui.sh`.
3.  Run the script with root privileges: `sudo ./setup_openwebui.sh`.
4.  Once the script completes successfully, Open WebUI should be accessible in your web browser at:
    ```
    http://localhost:3000
    ```

## Script Details

### Constants

The script uses the following constants, which you can modify to suit your needs:

*   `WEBUI_USER="udockeruser"`: The username for running the container.
*   `DATA_DIR="/content/open-webui"`: The directory for storing Open WebUI data.
*   `IMAGE_NAME="ghcr.io/open-webui/open-webui:main"`: The Open WebUI container image.
*   `CONTAINER_NAME="open-webui"`: The name of the created container.
*   `HOST_PORT="3000"`: The port on your host machine that will be mapped to the container port.
*   `CONTAINER_PORT="8080"`: The port that the Open WebUI container listens on.
*   `OLLAMA_URL="http://127.0.0.1:11434"`: The URL where the Ollama server is expected to be running.

### Functions

The script uses several functions to organize its functionality:

*   `print_message`: Prints colored messages to the console.
*   `check_root`: Checks if the script is run with root privileges.
*   `install_ollama`: Installs the Ollama server.
*   `start_ollama_serve`: Starts the Ollama server and verifies that it is reachable.
*   `create_user`: Creates the user to run the container.
*   `setup_directories`: Creates and configures the necessary directories.
*   `setup_container`: Pulls the Open WebUI image and creates the container using `udocker`.
*   `start_container`: Runs the Open WebUI container with the specified configurations.

## Troubleshooting

*   **Ollama Installation Failure:** If the Ollama installation fails, check your internet connection and make sure the Ollama installation script is available. Consider downloading the Ollama binary directly instead.
*   **Ollama Server Not Reachable:** If the Ollama server fails to start, check the output of the script for error messages. You might need to increase the `sleep` time in the `start_ollama_serve` function or check if there are any conflicts with other programs using the same port.
*   **Open WebUI Not Accessible:** If the Open WebUI is not accessible, check that the container is running correctly using `udocker ps -m -s`. Also, ensure that your firewall is not blocking access to port 3000.
*   **Port Conflicts:** If you encounter errors related to port 3000 already being in use, you can modify the `HOST_PORT` variable in the script to use a different port.

## Contributing

Contributions are welcome! If you have any improvements or suggestions, feel free to submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).
