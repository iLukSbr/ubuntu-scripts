#!/bin/bash

TMP_FOLDER="$(dirname "$(realpath "$0")")/../../tmp"
ZBAR_HEADERS_DIR=$TMP_FOLDER/zbar/include
DEST_DIR=/usr/local/include

# Create temporary directory
if [ -d $TMP_FOLDER ]; then
    sudo rm -rf $TMP_FOLDER
fi
sudo mkdir -p -m 777 $TMP_FOLDER
sudo chown -R $USER:$USER $TMP_FOLDER
cd $TMP_FOLDER || exit

# Download library
sudo git clone --recursive --depth 1 --branch 0.23.93 https://github.com/mchehab/zbar.git

sudo apt remove --purge *zbar*

sudo apt update
sudo apt-get -y install moc autoconf autopoint libpthread-stubs0-dev

cd $TMP_FOLDER/zbar || exit

# Generate moc files
sudo moc zbarcam/zbarcam-qt.cpp -o zbarcam/moc_zbarcam_qt.h
sudo chown -R $USER:$USER zbarcam/moc_zbarcam_qt.h
sudo chmod 777 zbarcam/moc_zbarcam_qt.h

# Copy .h files from zbar/include to /usr/local/include
sudo cp -f --preserve=mode,ownership $ZBAR_HEADERS_DIR/*.h $DEST_DIR/
sudo cp -f --preserve=mode,ownership zbarcam/moc_zbarcam_qt.h $DEST_DIR/

# Copy .h files from zbar/include/zbar to /usr/local/include/zbar
sudo mkdir -p -m 777 $DEST_DIR/zbar
sudo chown -R $USER:$USER $DEST_DIR/zbar
sudo cp -f --preserve=mode,ownership $ZBAR_HEADERS_DIR/zbar/*.h $DEST_DIR/zbar/

# Build and install ZBar
sudo autoreconf -vfi
sudo ./configure --prefix=/usr/local --includedir=/usr/local/include --libdir=/usr/local/lib --with-gtk=auto --with-python=auto --enable-codes=pdf417,ean,databar,code128,code93,code39,codabar,i25,qrcode,sqcode --without-java --enable-video=yes --with-gir=yes --with-jpeg=yes --with-dbus=yes --with-qt=no --with-x=yes
sudo make
sudo make install

# Remove temporary folder
cd ../..
sudo rm -rf $TMP_FOLDER

# List available ZBar packages
# sudo apt udpate
# zbar_packages=$(apt-cache search zbar | awk '{print $1}')

# Install found ZBar packages
# for package in $zbar_packages; do
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