#!/usr/bin/env bash

PROJECT_FOLDER="$(dirname "$(realpath "$0")")/../.."
PROJECT_PATH="${PROJECT_FOLDER/#$HOME\//}"
export HOSTNAME=$(hostname)

# Detect the GPU vendor and set the corresponding service name
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

# Get the ID of the running container based on the service name
CONTAINER_ID=$(docker ps -q --filter "name=${SERVICE_NAME}")

# Check if the container is running
if [ -n "$CONTAINER_ID" ]; then
    echo "Attaching a new terminal to the running container (${SERVICE_NAME})..."
    docker exec -it "$CONTAINER_ID" bash -c "cd /root/$PROJECT_PATH && exec bash"
else
    echo "Error: No running container found for service: $SERVICE_NAME"
    exit 1
fi
