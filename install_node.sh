#!/usr/bin/env bash
set -euo pipefail

# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash

# Instead of restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Download and install Node.js:
nvm install 24

# Check the Node.js version:
node -v
nvm current

# Verify the Node.js version:
node -v

# Check the npm version:
npm -v
npm install -g cline
