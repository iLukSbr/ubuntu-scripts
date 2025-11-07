#!/usr/bin/env bash
set -euo pipefail

if [ ! -f matlab_R2025b_Linux.zip ]; then
    echo "Download MATLAB zip installer here before running this script."
    exit 1
fi
mv matlab_R2025b_Linux.zip "$HOME/"
cd "$HOME/"
unzip matlab_R2025b_Linux.zip -d ./matlab_R2025b_Linux
cd ./matlab_R2025b_Linux
echo "You can install all packages if you have enough disk space."
xhost +SI:localuser:root
sudo -H ./install
xhost -SI:localuser:root
echo "Go to MATLAB resources and install MinGW-w64 support."
