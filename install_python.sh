#!/usr/bin/env bash
set -euo pipefail

sudo apt install python3-pip python3-venv software-properties-common -y
python3 -m pip install --upgrade pip setuptools wheel
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install python3.14 python3.14-venv -y
