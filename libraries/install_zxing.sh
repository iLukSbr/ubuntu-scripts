#!/bin/bash
set -euo pipefail

# Temporary and install directories
TMP_DIR="/tmp/zxing_install"
ZXING_REPO="https://github.com/zxing-cpp/zxing-cpp.git"
ZXING_BRANCH="v2.2.1"
INSTALL_LIB_DIR="/usr/local/lib"
INSTALL_INCLUDE_DIR="/usr/local/include/ZXing"

# Clean up any previous temp directory
if [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
fi
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

# Clone ZXing repository
git clone --recursive --depth 1 --branch "$ZXING_BRANCH" "$ZXING_REPO"

# Build ZXing
cd "$TMP_DIR/zxing-cpp"
if [ -d build ]; then rm -rf build; fi
mkdir build
cd build
cmake -S .. -B . -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DBUILD_WRITERS=ON -DBUILD_READERS=ON
cmake --build . -j"$(nproc)" --config Release

# Install library files
sudo cp -a libZXing* "$INSTALL_LIB_DIR/"

# Install headers
sudo mkdir -p "$INSTALL_INCLUDE_DIR"
sudo cp -a ../core/include/ZXing/* "$INSTALL_INCLUDE_DIR/"

# Clean up temp directory
cd /tmp
rm -rf "$TMP_DIR"

pip3 install -U pyzxing
