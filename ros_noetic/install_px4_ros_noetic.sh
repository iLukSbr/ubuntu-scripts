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

sudo sed -i 's|br.archive.ubuntu.com|archive.ubuntu.com|g' /etc/apt/sources.list
sudo apt-get update --fix-missing
sudo apt-get upgrade -y
sudo apt-get install -y \
    ros-${ROS_DISTRO}-desktop-full \
    wget \
    build-essential \
    cmake \
    git \
    python3-pip \
    python3-empy \
    python3-numpy \
    python3-yaml \
    protobuf-compiler \
    libeigen3-dev \
    libopencv-dev \
    python3-catkin-tools \
    python3-rosinstall-generator \
    geographiclib-tools \
    libgeographic19 \
    libgeographic-dev \
    python3-geographiclib \
    gazebo11 \
    libgazebo11-dev \
    ros-${ROS_DISTRO}-mavros \
    ros-${ROS_DISTRO}-mavros-extras \
    ros-${ROS_DISTRO}-mavros-msgs \
    ros-${ROS_DISTRO}-rosbash \
    ros-${ROS_DISTRO}-gazebo-ros-pkgs \
    ros-${ROS_DISTRO}-gazebo-ros-control \
    ros-${ROS_DISTRO}-unique-id \
    ros-${ROS_DISTRO}-uuid-msgs

cd "$HOME" || exit

if [ ! -d "PX4-Autopilot" ]; then
    git clone https://github.com/PX4/PX4-Autopilot.git --recursive
    bash ./PX4-Autopilot/Tools/setup/ubuntu.sh --no-nuttx
    echo "PX4-Autopilot cloned. Reboot Ubuntu and rerun this script to continue."
    exit 0
fi

wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh
sudo bash ./install_geographiclib_datasets.sh

if [ -d "$HOME/sim_ws" ]; then
    sudo rm -rf "$HOME/sim_ws"
fi
mkdir -p "$HOME/sim_ws/src"
cd "$HOME/sim_ws" || exit
catkin init
wstool init src
rosinstall_generator \
    --rosdistro "${ROS_DISTRO}" \
    mavlink mavros \
    --deps --wet-only | tee /tmp/mavros.rosinstall
wstool merge -t src /tmp/mavros.rosinstall
wstool update -t src -j4
rosdep install --from-paths src --ignore-src -y
sudo ./src/mavros/mavros/scripts/install_geographiclib_datasets.sh
catkin build

sudo usermod -a -G dialout "$USER"

if ! grep -q 'sim_ws/devel/setup.bash' ~/.bashrc; then
    echo 'source "$HOME/sim_ws/devel/setup.bash"' >> ~/.bashrc
fi
if ! grep -q 'PX4-Autopilot/Tools/simulation/gazebo-classic/setup_gazebo.bash' ~/.bashrc; then
    echo 'source "$HOME/PX4-Autopilot/Tools/simulation/gazebo-classic/setup_gazebo.bash" "$HOME/PX4-Autopilot" "$HOME/PX4-Autopilot/build/px4_sitl_default"' >> ~/.bashrc
fi
if ! grep -q 'ROS_PACKAGE_PATH=' ~/.bashrc; then
    echo 'export ROS_PACKAGE_PATH="$ROS_PACKAGE_PATH:$HOME/PX4-Autopilot:$HOME/PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_gazebo-classic"' >> ~/.bashrc
fi
if ! grep -q 'GAZEBO_PLUGIN_PATH=' ~/.bashrc; then
    echo 'export GAZEBO_PLUGIN_PATH="$GAZEBO_PLUGIN_PATH:/usr/lib/x86_64-linux-gnu/gazebo-9/plugins"' >> ~/.bashrc
fi
if ! grep -q 'PX4-Autopilot/build/px4_sitl_default/bin' ~/.bashrc; then
    echo 'export PATH="$HOME/PX4-Autopilot/build/px4_sitl_default/bin:$PATH"' >> ~/.bashrc
fi
if ! grep -q 'build/px4_sitl_default/build_gazebo' ~/.bashrc; then
    echo 'export PYTHONPATH="$PYTHONPATH:$HOME/PX4-Autopilot/build/px4_sitl_default/build_gazebo"' >> ~/.bashrc
fi

source devel/setup.bash
