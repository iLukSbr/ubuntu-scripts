#!/usr/bin/env bash
set -euo pipefail

sudo add-apt-repository multiverse -y
sudo apt-get update
sudo apt-get install ubuntu-restricted-extras -y
sudo apt-get upgrade -y
