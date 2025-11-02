#!/bin/bash

TMP_FOLDER="$(dirname "$(realpath "$0")")/../../tmp"
LIB_FOLDER="/usr/local/lib"

# Create temporary directory
if [ -d $TMP_FOLDER ]; then
    sudo rm -rf $TMP_FOLDER
fi
sudo mkdir -p -m 777 $TMP_FOLDER
sudo chown -R $USER:$USER $TMP_FOLDER
cd $TMP_FOLDER || exit

# Download library
sudo git clone --recursive --depth 1 --branch v2.2.1 https://github.com/zxing-cpp/zxing-cpp.git

# Build and install ZXing
cd $TMP_FOLDER/zxing-cpp || exit
if [ -d build ]; then sudo rm -rf build; fi
if [ -d /usr/local/include/ZXing ]; then rm -rf $LIB_FOLDER/zxing-cpp; fi
sudo mkdir -p -m 777 $TMP_FOLDER/zxing-cpp/build
sudo chown -R $USER:$USER $TMP_FOLDER/zxing-cpp/build
cd $TMP_FOLDER/zxing-cpp/build || exit
sudo cmake -S .. -B . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$LIB_FOLDER/zxing-cpp -DBUILD_SHARED_LIBS=ON -DBUILD_WRITERS=ON -DBUILD_READERS=ON
sudo cmake --build . -j"$(nproc)" --config Release
sudo make -j"$(nproc)"
sudo make install

# Remove temporary folder
cd ../..
sudo rm -rf $TMP_FOLDER

# List available ZXing packages
# sudo apt update
# zxing_packages=$(apt-cache search zxing | awk '{print $1}')

# Install found ZXing packages
# for package in $zxing_packages; do
#     if [[ "$package" == *"ros"* || "$package" == *"python2"* ]]; then
#         # echo "Skipping $package (ROS or Python2 package)"
#         continue
#     fi
#     echo "Attempting to install $package..."
#     sudo apt-get install -y -qq "$package" > /dev/null || true
#     if [ $? -ne 0 ]; then
#         echo "Failed to install $package" >&2
#     else
#         echo "Successfully installed $package"
#     fi
# done