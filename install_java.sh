#!/usr/bin/env bash
set -euo pipefail

sudo apt install openjdk-25-jre openjdk-25-jdk -y
java -version
javac -version
wget https://download.oracle.com/java/25/latest/jdk-25_linux-x64_bin.deb
sudo apt-get install ./jdk-25_linux-x64_bin.deb -y
java -version
javac -version
