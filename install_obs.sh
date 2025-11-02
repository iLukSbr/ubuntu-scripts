#!/usr/bin/env bash
set -euo pipefail

sudo apt-get install ffmpeg -y
sudo add-apt-repository ppa:obsproject/obs-studio
sudo apt update
sudo apt-get install obs-studio -y
