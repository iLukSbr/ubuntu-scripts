#!/usr/bin/env bash
set -euo pipefail

wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.4.38621.tar.gz
tar -zxvf jetbrains-toolbox-2.5.4.38621.tar.gz
cd jetbrains-toolbox-2.5.4.38621
sudo apt update
sudo apt install libfuse-dev -y
./jetbrains-toolbox
