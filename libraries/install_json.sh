#!/bin/bash

EXT_FOLDER="$(dirname "$(realpath "$0")")/../../extern"

if [ ! -d "$EXT_FOLDER" ]; then
    sudo mkdir -p -m 777 $EXT_FOLDER
    sudo chown -R $USER:$USER $EXT_FOLDER
fi

cd $EXT_FOLDER || exit

sudo apt-get update
sudo apt-get install -y jq

# Clone json as submodule
git submodule add --branch develop https://github.com/nlohmann/json
cd json
git checkout v3.11.3
cd ..
git submodule update --init --recursive
