#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev libstdc++-12-dev curl git unzip xz-utils zip libglu1-mesa

# Install SDKMAN (Software Development Kit Manager)
echo "Installing SDKMAN..."
curl -s "https://get.sdkman.io" | bash

# Source SDKMAN init script (temporarily disable -u to avoid unbound variable errors)
echo "Initializing SDKMAN..."
set +u
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Install Gradle using SDKMAN
echo "Installing Gradle 9.2.0..."
sdk install gradle 9.2.0
set -u

# Download and extract Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.35.7-stable.tar.xz -O /tmp/flutter.tar.xz
sudo tar xf /tmp/flutter.tar.xz -C /opt
rm /tmp/flutter.tar.xz

# Add Flutter to PATH in bashrc
FLUTTER_PATH_LINE='export PATH="$PATH:/opt/flutter/bin"'
if ! grep -qF "$FLUTTER_PATH_LINE" "$HOME/.bashrc"; then
    echo "$FLUTTER_PATH_LINE" >> "$HOME/.bashrc"
    echo "Flutter added to PATH in $HOME/.bashrc"
else
    echo "Flutter already in PATH in $HOME/.bashrc"
fi

# Add Flutter to current session PATH
export PATH="$PATH:/opt/flutter/bin"

# Run flutter doctor to verify installation
echo "Running flutter doctor..."
flutter doctor
