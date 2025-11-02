#!/usr/bin/env bash

PROJECT_FOLDER="$(dirname "$(realpath "$0")")/../.."
PROJECT_PATH="${PROJECT_FOLDER/#$HOME\//}"
HOSTNAME=$(hostname)
export HOSTNAME="$HOSTNAME"

# Check if xauth command is available
if ! command -v xauth &> /dev/null; then
    echo "xauth command not found. Installing xauth..."
    sudo apt-get update
    sudo apt-get install -y xauth
fi

# Allow local user to access X server
xhost +SI:localuser:"$(whoami)"

# Function to find an available display
find_available_display() {
    for i in {0..10}; do
        if ! xset q &>/dev/null; then
            echo ":$i"
            return
        fi
    done
    echo "No available display found. Exiting..."
    exit 1
}

# Set DISPLAY to an available display if not already set
if [ -z "$DISPLAY" ]; then
    DISPLAY=$(find_available_display)
    export DISPLAY
fi

# Create the .Xauthority file if it doesn't exist
if [ ! -f "$HOME/.Xauthority" ]; then
    echo "Creating .Xauthority file..."
    touch "$HOME/.Xauthority"
    xauth generate "$DISPLAY" . trusted
fi

# Create the /tmp/.docker.xauth file if it doesn't exist
if [ ! -f /tmp/.docker.xauth ]; then
    echo "Creating /tmp/.docker.xauth file..."
    touch /tmp/.docker.xauth
fi

# Remove stale lock files and ensure proper permissions
rm -f /tmp/.docker.xauth*
sudo chmod 777 /tmp/.docker.xauth

# Set the XAUTHORITY environment variable to the system's .Xauthority file
export XAUTHORITY="$HOME/.Xauthority"

# Ensure the X server is allowing connections from local users
xhost +local:docker || { echo "Failed to configure X server"; exit 1; }

# Set up display connection port permissions
sudo chmod -R 777 "$PROJECT_FOLDER"

# Set environment variables for Docker
export X11_SOCKET="/tmp/.X11-unix"
export XAUTHORITY_FILE="$XAUTHORITY"

# Remove old docker containers
docker compose down --remove-orphans

# Detect Jetson first, then other GPUs
if uname -a | grep -qi tegra || grep -qi nvidia /proc/device-tree/model 2>/dev/null; then
    echo "NVIDIA Jetson device detected. Running Jetson docker-compose configuration..."
    SERVICE_NAME="ros_nvidia_jetson"
elif lspci | grep -i nvidia > /dev/null; then
    echo "NVIDIA GPU detected. Running NVIDIA docker-compose configuration..."
    SERVICE_NAME="ros_nvidia_linux"
elif lspci | grep -i amd > /dev/null; then
    echo "AMD GPU detected. Running AMD docker-compose configuration..."
    SERVICE_NAME="ros_amd_linux"
elif lspci | grep -i intel > /dev/null; then
    echo "Intel GPU detected. Running Intel docker-compose configuration..."
    SERVICE_NAME="ros_intel_linux"
else
    echo "No supported GPU found. Running default docker-compose configuration..."
    SERVICE_NAME="ros_default_linux"
fi

# Build only the detected service
echo "Building Docker container for service: $SERVICE_NAME..."
docker compose -f "$PROJECT_FOLDER/.devcontainer/docker-compose.yaml" build "$SERVICE_NAME" || { echo "Failed to build Docker container for service: $SERVICE_NAME"; exit 1; }

# Start the detected service
docker compose -f "$PROJECT_FOLDER/.devcontainer/docker-compose.yaml" up -d "$SERVICE_NAME" || { echo "Failed to start the service: $SERVICE_NAME"; exit 1; }

# Fix container name construction issue
CONTAINER_ID=$(docker ps -q --filter "name=${SERVICE_NAME}")
if [ -z "$CONTAINER_ID" ]; then
    echo "Error: No running container found for service: $SERVICE_NAME"
    exit 1
fi

# Open a new interactive terminal in the running container
echo "Opening a new terminal in the running container..."
docker exec -it "$CONTAINER_ID" bash -c "cd /root/$PROJECT_PATH && exec bash"
