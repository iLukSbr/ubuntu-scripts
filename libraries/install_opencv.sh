#!/bin/bash
set -euo pipefail

TMP_FOLDER="/tmp/opencv_install"
LIB_FOLDER="/usr/local/lib"
OPENCV_INSTALL="$LIB_FOLDER/opencv"

# Clean and prepare temporary folder
rm -rf "$TMP_FOLDER"
mkdir -p "$TMP_FOLDER"
cd "$TMP_FOLDER"

# Download OpenCV and contrib
if [ ! -d opencv ]; then
    git clone --recursive --depth 1 --branch 4.12.0 https://github.com/opencv/opencv.git
fi
if [ ! -d opencv_contrib ]; then
    git clone --recursive --depth 1 --branch 4.12.0 https://github.com/opencv/opencv_contrib.git
fi

# Remove previous build and installation
rm -rf "$TMP_FOLDER/opencv/build"
sudo rm -rf "$OPENCV_INSTALL"

# Prepare build
mkdir -p "$TMP_FOLDER/opencv/build"
cd "$TMP_FOLDER/opencv/build"

cmake -DCMAKE_INSTALL_PREFIX="$OPENCV_INSTALL" \
      -DOPENCV_EXTRA_MODULES_PATH="$TMP_FOLDER/opencv_contrib/modules" \
      -DBUILD_opencv_legacy=ON \
      -DBUILD_opencv_world=ON \
      -DBUILD_EXAMPLES=ON \
      -DBUILD_OPENJPEG:BOOL=ON \
      -DWITH_CUDA=ON \
      -DWITH_CUDNN=ON \
      -DWITH_CUBLAS=ON \
      -DENABLE_FAST_MATH=ON \
      -DCUDA_FAST_MATH=ON \
      -DWITH_CUFFT=ON \
      -DCUDA_ARCH_BIN="6.1;7.5;8.6" \
      -DCUDA_ARCH_PTX="" \
      -DBUILD_opencv_python3=ON \
      -DBUILD_opencv_java=ON \
      -DBUILD_opencv_js=ON \
      -DBUILD_opencv_dnn=ON \
      -DBUILD_opencv_imgcodecs=ON \
      -DBUILD_opencv_imgproc=ON \
      -DBUILD_opencv_highgui=ON \
      -DBUILD_opencv_features2d=ON \
      -DBUILD_opencv_calib3d=ON \
      -DBUILD_opencv_video=ON \
      -DBUILD_opencv_videoio=ON \
      -DBUILD_opencv_objdetect=ON \
      -DBUILD_opencv_flann=ON \
      -DBUILD_opencv_ml=ON \
      -DBUILD_opencv_photo=ON \
      -DBUILD_opencv_stitching=ON \
      -DBUILD_opencv_superres=ON \
      -DBUILD_opencv_videostab=ON \
      -DBUILD_opencv_xfeatures2d=ON \
      -DBUILD_opencv_ximgproc=ON \
      -DBUILD_opencv_xphoto=ON \
      -DBUILD_opencv_xobjdetect=ON \
      -DBUILD_opencv_xstitching=ON \
      -DBUILD_opencv_xvideo=ON ..
make -j"$(nproc)"
sudo make install

# Clean temporary folder
cd /tmp
rm -rf "$TMP_FOLDER"

# Add to LD_LIBRARY_PATH if needed
if ! grep -qxF "export LD_LIBRARY_PATH=$OPENCV_INSTALL/lib:\$LD_LIBRARY_PATH" "$HOME/.bashrc"; then
    echo "export LD_LIBRARY_PATH=$OPENCV_INSTALL/lib:\$LD_LIBRARY_PATH" >> "$HOME/.bashrc"
fi

# End
