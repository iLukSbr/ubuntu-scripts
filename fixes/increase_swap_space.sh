#!/usr/bin/env bash

# Increase the swap space to 8GB (check your RAM size before increasing the swap space)
SWAP_SIZE=8G

# Turn off the swap file
sudo swapoff /swapfile

# Remove the swap file
sudo rm /swapfile

# Remove the swap file entry from /etc/fstab
sudo sed -i '/\/swapfile/d' /etc/fstab

# Create a swap file of 16GB
sudo fallocate -l $SWAP_SIZE /swapfile

# Set the correct permissions
sudo chmod 600 /swapfile

# Set up the swap space
sudo mkswap /swapfile

# Enable the swap space
sudo swapon /swapfile

# Verify the swap space
sudo swapon --show

# Make the swap space permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
