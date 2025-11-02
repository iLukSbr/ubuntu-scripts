#!/usr/bin/env bash
set -euo pipefail

sudo add-apt-repository ppa:dotnet/backports -y
sudo apt-get update
sudo apt-get install -y dotnet-sdk-9.0 aspnetcore-runtime-9.0
dotnet --version
