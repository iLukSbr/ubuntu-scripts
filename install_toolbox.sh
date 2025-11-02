#!/usr/bin/env bash
set -euo pipefail

wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.4.38621.tar.gz
tar -zxvf jetbrains-toolbox-2.5.4.38621.tar.gz
cd jetbrains-toolbox-2.5.4.38621
sudo apt-get update
sudo apt-get install libfuse-dev -y
./jetbrains-toolbox
