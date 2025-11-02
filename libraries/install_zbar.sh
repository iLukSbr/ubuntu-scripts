#!/bin/bash
set -euo pipefail

TMP_FOLDER="/tmp/zbar_install"
ZBAR_HEADERS_DIR="$TMP_FOLDER/zbar/include"
DEST_DIR="/usr/local/include"

# Clean and prepare temporary directory
sudo rm -rf "$TMP_FOLDER"
mkdir -p "$TMP_FOLDER"
cd "$TMP_FOLDER"

# Download library
if [ ! -d zbar ]; then
    git clone --recursive --depth 1 --branch 0.23.93 https://github.com/mchehab/zbar.git
fi

sudo apt remove --purge -y '*zbar*'
sudo apt-get update
sudo apt-get -y install moc autoconf autopoint libpthread-stubs0-dev

cd "$TMP_FOLDER/zbar"

# Generate moc files
moc zbarcam/zbarcam-qt.cpp -o zbarcam/moc_zbarcam_qt.h
chmod 644 zbarcam/moc_zbarcam_qt.h

# Copy .h files from zbar/include to /usr/local/include
sudo cp -f $ZBAR_HEADERS_DIR/*.h $DEST_DIR/
sudo cp -f zbarcam/moc_zbarcam_qt.h $DEST_DIR/

# Copy .h files from zbar/include/zbar to /usr/local/include/zbar
sudo mkdir -p $DEST_DIR/zbar
sudo cp -f $ZBAR_HEADERS_DIR/zbar/*.h $DEST_DIR/zbar/

# Build and install ZBar
autoreconf -vfi
./configure --prefix=/usr/local --includedir=/usr/local/include --libdir=/usr/local/lib --with-gtk=auto --with-python=auto --enable-codes=pdf417,ean,databar,code128,code93,code39,codabar,i25,qrcode,sqcode --without-java --enable-video=yes --with-gir=yes --with-jpeg=yes --with-dbus=yes --with-qt=no --with-x=yes
make -j"$(nproc)"
sudo make install

# Remove temporary folder
cd /tmp
sudo rm -rf "$TMP_FOLDER"

pip3 install -U pyzbar
