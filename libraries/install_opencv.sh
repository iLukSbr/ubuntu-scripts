#!/bin/bash

TMP_FOLDER="$(dirname "$(realpath "$0")")/../../tmp"
LIB_FOLDER="/usr/local/lib"
EXT_FOLDER="$TMP_FOLDER/../extern"

# Create temporary directory
if [ -d $TMP_FOLDER ]; then
    sudo rm -rf $TMP_FOLDER
fi
sudo mkdir -p -m 777 $TMP_FOLDER
sudo chown -R $USER:$USER $TMP_FOLDER
cd $TMP_FOLDER || exit

# Download libraries
sudo git clone --recursive --depth 1 --branch 4.10.0 https://github.com/opencv/opencv.git
sudo git clone --recursive --depth 1 --branch 4.10.0 https://github.com/opencv/opencv_contrib.git

if [ ! -d "$EXT_FOLDER" ]; then
    sudo mkdir -p -m 777 $EXT_FOLDER
    sudo chown -R $USER:$USER $EXT_FOLDER
fi

cd $EXT_FOLDER || exit

# Clone TensorFlow Super Resolution models as submodule
git submodule add --depth 1 --branch master https://github.com/fannymonori/TF-ESPCN.git
git submodule update --init --recursive

# Clone OpenCV Super Resolution models as submodule
git submodule add --branch wechat_qrcode_20210119 https://github.com/opencv/opencv_3rdparty.git
git submodule update --init --recursive

# Build and install OpenCV
cd $TMP_FOLDER/opencv || exit
if [ -d build ]; then sudo rm -rf build; fi
if [ -d /usr/local/include/opencv4 ]; then sudo rm -rf $LIB_FOLDER/opencv; fi
sudo mkdir -p -m 777 $TMP_FOLDER/opencv/build
sudo chown -R $USER:$USER $TMP_FOLDER/opencv/build
cd $TMP_FOLDER/opencv/build || exit
sudo cmake -DCMAKE_INSTALL_PREFIX=$LIB_FOLDER/opencv -DOPENCV_EXTRA_MODULES_PATH=$TMP_FOLDER/opencv_contrib/modules -DBUILD_opencv_legacy=ON -DBUILD_EXAMPLES=ON -DBUILD_OPENJPEG:BOOL=ON ..
sudo make -j"$(nproc)"
sudo make install

# Remove temporary folder
cd ../..
sudo rm -rf $TMP_FOLDER

# Add to runtime path
grep -qxF 'export LD_LIBRARY_PATH=/usr/local/lib/opencv/lib:$LD_LIBRARY_PATH' ~/.bashrc || echo 'export LD_LIBRARY_PATH=/usr/local/lib/opencv/lib:$LD_LIBRARY_PATH' | sudo tee -a ~/.bashrc

# List available OpenCV packages
# sudo apt update
# opencv_packages=$(apt-cache search opencv | awk '{print $1}')

# Install OpenCV packages
# for package in $opencv_packages; do
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