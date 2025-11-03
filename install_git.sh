#!/usr/bin/env bash

# Install GitHub CLI
sudo apt-get update
sudo apt-get install -y wget
(type -p wget >/dev/null || (sudo apt-get update && sudo apt-get install wget -y))
sudo mkdir -p -m 755 /etc/apt/keyrings
sudo wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt-get update
sudo apt-get install git git-gui gh firefox -y
gh extension install github/gh-copilot
echo "Go to Edit -> Options -> Fill Repos and Global fields with your GitHub username and e-mail"
git-gui
gh auth login
