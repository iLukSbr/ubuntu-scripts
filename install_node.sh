#!/usr/bin/env bash
set -euo pipefail

# Descarregar e instalar a nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash

# Em vez de reiniciar a concha ou shell
\. "$HOME/.nvm/nvm.sh"

# Descarregar e instalar a Node.js:
nvm install 24

# Consultar a versão da Node.js:
node -v # Deveria imprimir "v24.11.0".
nvm current # Deveria imprimir "v24.11.0".

# Verify the Node.js version:
node -v # Should print "v24.11.0".

# Consultar a versão da npm:
npm -v # Deveria imprimir "11.6.1".
npm install -g cline
