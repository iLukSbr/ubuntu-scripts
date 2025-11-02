#!/usr/bin/env bash
set -euo pipefail

sudo add-apt-repository multiverse -y
sudo apt update
sudo apt install ubuntu-restricted-extras -y
sudo apt upgrade -y
