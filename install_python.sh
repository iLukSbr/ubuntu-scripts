#!/usr/bin/env bash
set -euo pipefail

# Add $HOME/.local/bin to PATH in $HOME/.bashrc if not already present
LOCAL_BIN_LINE='export PATH="$HOME/.local/bin${PATH:+:${PATH}}"'

if ! grep -qF "$LOCAL_BIN_LINE" "$HOME/.bashrc"; then
    echo "$LOCAL_BIN_LINE" >> "$HOME/.bashrc"
    echo "\$HOME/.local/bin added to PATH in $HOME/.bashrc"
else
    echo "\$HOME/.local/bin already in PATH in $HOME/.bashrc"
fi

sudo apt-get install python3-pip python3-venv software-properties-common -y
python3 -m pip install --upgrade pip setuptools wheel
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt-get update
sudo apt-get install python3-full python3.14-full python3.14-dev python3.14-venv -y
