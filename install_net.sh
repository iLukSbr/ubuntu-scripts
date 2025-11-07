#!/usr/bin/env bash
set -euo pipefail

sudo add-apt-repository ppa:dotnet/backports -y
sudo apt-get update
sudo apt-get install -y dotnet-sdk-9.0 aspnetcore-runtime-9.0
# Remove conflicting package if installed (prevents upgrade error)
sudo apt remove netstandard-targeting-pack-2.1-9.0 || true
sudo apt-get upgrade -y
dotnet --version
