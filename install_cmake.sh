#!/usr/bin/env bash
set -euo pipefail

# Atualiza apt e instala ferramentas necessárias
sudo apt-get update
sudo apt-get install -y ca-certificates gpg wget lsb-release doxygen

# Instala o keyring do Kitware (se ainda não estiver instalado)
if ! test -f /usr/share/doc/kitware-archive-keyring/copyright; then
	wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null \
		| gpg --dearmor - \
		| sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
fi

# Detecta o codename da distribuição (ex: noble, jammy, focal)
CODENAME=""
if [ -r /etc/os-release ]; then
	. /etc/os-release
	CODENAME=${VERSION_CODENAME:-}
fi

if [ -z "$CODENAME" ]; then
	CODENAME=$(lsb_release -sc 2>/dev/null || true)
fi

case "${CODENAME}" in
	noble|jammy|focal)
		echo "Detected Ubuntu codename: ${CODENAME}"
		;;
	"")
		echo "Não foi possível detectar o codename do Ubuntu. Saindo." >&2
		exit 1
		;;
	*)
		echo "Aviso: codename detectado '${CODENAME}' não é um dos testados (noble/jammy/focal). Tentando adicionar o repositório para esse codename." >&2
		;;
esac

# Adiciona o repositório Kitware correspondente e atualiza os pacotes
echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ ${CODENAME} main" \
	| sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null

sudo apt-get update
sudo apt-get install -y kitware-archive-keyring
sudo apt-get update
sudo apt-get install cmake -y
cmake --version
