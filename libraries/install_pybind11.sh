#!/bin/bash

EXT_FOLDER="$(dirname "$(realpath "$0")")/../../extern"

if [ ! -d "$EXT_FOLDER" ]; then
    sudo mkdir -p -m 777 $EXT_FOLDER
    sudo chown -R $USER:$USER $EXT_FOLDER
fi

cd $EXT_FOLDER || exit

# Clone pybind11 as submodule
git submodule add --branch stable https://github.com/pybind/pybind11
git submodule update --init --recursive

