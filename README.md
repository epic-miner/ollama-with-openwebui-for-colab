# Open WebUI Manager

A bash script for managing Open WebUI container using udocker. This script provides easy-to-use commands for setting up, running, backing up, and updating Open WebUI installations.

## Prerequisites

- Root/sudo access
- udocker installed on your system
- Ollama running and accessible

## Installation

1. Download the script:
```bash
curl -O https://raw.githubusercontent.com/yourrepo/webui-manager.sh
```

2. Make it executable:
```bash
chmod +x webui-manager.sh
```

## Configuration

The script uses the following default settings which can be modified in the script:

- User: `udockeruser`
- Data Directory: `/content/open-webui`
- Container Name: `open-webui`
- Host Port: `3000`
- Container Port: `8080`
- Image: `ghcr.io/open-webui/open-webui:main`

## Usage

### Initial Setup

To set up and start Open WebUI for the first time:

```bash
sudo ./webui-manager.sh setup http://your-ollama-url:11434
```

This command will:
- Create a dedicated user (udockeruser)
- Set up necessary directories
- Pull the Open WebUI container
- Start the container

### Starting the Container

To start an existing container:

```bash
sudo ./webui-manager.sh start http://your-ollama-url:11434
```

### Backup and Restore

Create a backup:
```bash
sudo ./webui-manager.sh backup
```
Backups are saved as `webui-backup-YYYYMMDD-HHMMSS.tar.gz` in the current directory.

Restore from a backup:
```bash
sudo ./webui-manager.sh restore webui-backup-20240319-123456.tar.gz
```

### Updating

To update the container to the latest version:

```bash
sudo ./webui-manager.sh update
```

## Command Reference

```bash
./webui-manager.sh [command] [options]

Commands:
    setup <ollama_url>     - Initial setup and start (requires ollama_url)
    start <ollama_url>     - Start existing container
    backup                 - Create backup
    restore <backup_file>  - Restore from backup
    update                 - Update container
    help                   - Show this help
```

## Directory Structure

```
/content/open-webui/
└── data/               # Persistent data storage
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Make sure you're running the script with sudo
   - Check if udockeruser has correct permissions

2. **Container Won't Start**
   - Verify Ollama URL is correct and accessible
   - Check if port 3000 is available
   - Ensure udocker is properly installed

3. **Backup/Restore Fails**
   - Check available disk space
   - Verify backup file exists for restore
   - Ensure write permissions in current directory

### Logs

To check container logs:
```bash
su - udockeruser -c "udocker logs open-webui"
```

## Security Considerations

- The script creates a dedicated user (udockeruser) for running the container
- All operations requiring elevated privileges need sudo
- Data directory permissions are set to 755
- Container runs as non-root user

## Contributing

Feel free to submit issues and enhancement requests!

## License

[Add your license information here]
