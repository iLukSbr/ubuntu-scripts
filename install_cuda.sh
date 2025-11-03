#!/usr/bin/env bash
set -euo pipefail

# Check if running on Ubuntu 22.04
if [ ! -f /etc/os-release ] || ! grep -q "VERSION_ID=\"22.04\"" /etc/os-release; then
    echo "Error: This script is designed for Ubuntu 22.04 (Jammy Jellyfish)"
    exit 1
fi

wget -P /tmp https://developer.download.nvidia.com/compute/cuda/13.0.2/local_installers/cuda_13.0.2_580.95.05_linux.run
sudo sh /tmp/cuda_13.0.2_580.95.05_linux.run
rm /tmp/cuda_13.0.2_580.95.05_linux.run

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

# cuDNN
wget -P /tmp https://developer.download.nvidia.com/compute/cudnn/9.14.0/local_installers/cudnn-local-repo-ubuntu2204-9.14.0_1.0-1_amd64.deb
sudo dpkg -i /tmp/cudnn-local-repo-ubuntu2204-9.14.0_1.0-1_amd64.deb
sudo cp /var/cudnn-local-repo-ubuntu2204-9.14.0/cudnn-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cudnn
rm /tmp/cudnn-local-repo-ubuntu2204-9.14.0_1.0-1_amd64.deb

nvcc --version

# cuBLAS
curl https://developer.download.nvidia.com/hpc-sdk/ubuntu/DEB-GPG-KEY-NVIDIA-HPC-SDK | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-hpcsdk-archive-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/nvidia-hpcsdk-archive-keyring.gpg] https://developer.download.nvidia.com/hpc-sdk/ubuntu/amd64 /' | sudo tee /etc/apt/sources.list.d/nvhpc.list
sudo apt-get update -y
sudo apt-get install -y nvhpc-25-9

# mathDx
cd "$HOME" || exit
wget -P /tmp https://developer.nvidia.com/downloads/compute/cuFFTDx/redist/cuFFTDx/cuda13/nvidia-mathdx-25.06.1-cuda13.tar.gz
tar -zxvf /tmp/nvidia-mathdx-25.06.1-cuda13.tar.gz -C "$HOME"
rm /tmp/nvidia-mathdx-25.06.1-cuda13.tar.gz
MATHDX_INCLUDE_LINE="export CPLUS_INCLUDE_PATH=\$HOME/nvidia-mathdx-25.06.1/nvidia/mathdx/25.06/include\${CPLUS_INCLUDE_PATH:+:\${CPLUS_INCLUDE_PATH}}"
MATHDX_LD_LINE="export LD_LIBRARY_PATH=\$HOME/nvidia-mathdx-25.06.1/nvidia/mathdx/25.06/lib\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}"
if ! grep -qF "$MATHDX_INCLUDE_LINE" "$HOME/.bashrc"; then
    echo "$MATHDX_INCLUDE_LINE" >> "$HOME/.bashrc"
    echo "MathDx CPLUS_INCLUDE_PATH added to $HOME/.bashrc"
else
    echo "MathDx CPLUS_INCLUDE_PATH already in $HOME/.bashrc"
fi
if ! grep -qF "$MATHDX_LD_LINE" "$HOME/.bashrc"; then
    echo "$MATHDX_LD_LINE" >> "$HOME/.bashrc"
    echo "MathDx LD_LIBRARY_PATH added to $HOME/.bashrc"
else
    echo "MathDx LD_LIBRARY_PATH already in $HOME/.bashrc"
fi
