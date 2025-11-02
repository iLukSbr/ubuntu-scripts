#!/usr/bin/env bash

ROS_DISTRO=noetic

# Check the Ubuntu version
UBUNTU_VERSION=$(lsb_release -rs)
if [ "$UBUNTU_VERSION" != "20.04" ]; then
    echo "This script requires Ubuntu 20.04. Detected version: $UBUNTU_VERSION"
    exit 1
fi

# Verify Python version
PYTHON_VERSION_FULL=$(python3 --version 2>&1 | awk '{print $2}')
PYTHON_MAJOR=$(echo "$PYTHON_VERSION_FULL" | cut -d. -f1)
PYTHON_MINOR=$(echo "$PYTHON_VERSION_FULL" | cut -d. -f2)
if [ "$PYTHON_MAJOR" -ne 3 ] || [ "$PYTHON_MINOR" -lt 8 ] || [ "$PYTHON_MINOR" -ge 9 ]; then
    echo "Error: ROS Noetic requires Python >= 3.8.0 and < 3.9, but found $PYTHON_VERSION_FULL"
    exit 1
fi

# Remove any existing ROS repository lists to avoid duplicates
sudo rm -f /etc/apt/sources.list.d/ros-latest.list
sudo rm -f /etc/apt/sources.list.d/ros1-latest.list

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
sudo apt-get update
sudo apt-get install -y "ros-${ROS_DISTRO}-desktop-full"

if [ -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
    sudo rm /etc/ros/rosdep/sources.list.d/20-default.list
fi

# Add to .bashrc
sed -i '/source \/opt\/ros\/.*\/setup.bash/d' "$HOME/.bashrc"
echo "source /opt/ros/noetic/setup.bash" >> "$HOME/.bashrc"
source /opt/ros/noetic/setup.bash

if ! grep -q '/opt/ros/noetic/lib/python3/dist-packages' "$HOME/.bashrc"; then
    echo 'export PYTHONPATH="$PYTHONPATH:/opt/ros/noetic/lib/python3/dist-packages"' >> "$HOME/.bashrc"
fi

if grep -q 'export LD_LIBRARY_PATH=' "$HOME/.bashrc"; then
    if ! grep -q "/opt/ros/noetic/lib" "$HOME/.bashrc"; then
        sed -i "s|export LD_LIBRARY_PATH=|export LD_LIBRARY_PATH=\"/opt/ros/noetic/lib:\$LD_LIBRARY_PATH\"|" "$HOME/.bashrc"
    fi
else
    echo 'export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/ros/noetic/lib"' >> "$HOME/.bashrc"
fi

sudo apt-get install -y \
    python3-catkin-tools \
    python3-rosdep \
    python3-roslaunch \
    python3-dev \
    python3-pip \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    python3-rospkg \
    python3-rospy \
    python3-venv \
    doxygen
sudo python3 -m pip install --upgrade pip
sudo dpkg -i --force-overwrite /var/cache/apt/archives/python3-catkin-pkg-modules_1.0.0-1_all.deb
sudo usermod -a -G dialout "$USER"

# Initialize rosdep
sudo rosdep init
rosdep update
