#!/usr/bin/env bash
set -euo pipefail

# Check if running on Ubuntu 22.04
if [ ! -f /etc/os-release ] || ! grep -q "VERSION_ID=\"22.04\"" /etc/os-release; then
    echo "Error: This script is designed for Ubuntu 22.04 (Jammy Jellyfish)"
    exit 1
fi

wget https://developer.download.nvidia.com/compute/cuda/13.0.2/local_installers/cuda_13.0.2_580.95.05_linux.run
sudo sh cuda_13.0.2_580.95.05_linux.run

# Add CUDA paths to $HOME/.bashrc if not already present
CUDA_PATH_LINE='export PATH=/usr/local/cuda-13.0/bin${PATH:+:${PATH}}'
CUDA_LD_LINE='export LD_LIBRARY_PATH=/usr/local/cuda-13.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}'

if ! grep -qF "$CUDA_PATH_LINE" "$HOME/.bashrc"; then
    echo "$CUDA_PATH_LINE" >> "$HOME/.bashrc"
    echo "CUDA PATH added to $HOME/.bashrc"
else
    echo "CUDA PATH already in $HOME/.bashrc"
fi

if ! grep -qF "$CUDA_LD_LINE" "$HOME/.bashrc"; then
    echo "$CUDA_LD_LINE" >> "$HOME/.bashrc"
    echo "CUDA LD_LIBRARY_PATH added to $HOME/.bashrc"
else
    echo "CUDA LD_LIBRARY_PATH already in $HOME/.bashrc"
fi

wget https://developer.download.nvidia.com/compute/cudnn/9.14.0/local_installers/cudnn-local-repo-ubuntu2204-9.14.0_1.0-1_amd64.deb
sudo dpkg -i cudnn-local-repo-ubuntu2204-9.14.0_1.0-1_amd64.deb
sudo cp /var/cudnn-local-repo-ubuntu2204-9.14.0/cudnn-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cudnn

nvcc --version
