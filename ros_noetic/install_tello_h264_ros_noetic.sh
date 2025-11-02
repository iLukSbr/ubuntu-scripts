#!/usr/bin/env bash

# Installs H264 streaming version of Tello driver

# Configuration
TELLO_DRIVER_DIR="$HOME/tello_driver_ws"
ROS_DISTRO=noetic

# Function to check if a package is installed
check_package() {
    dpkg -l "$1" &> /dev/null
    return $?
}

# Function to check if a command succeeded
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

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

# Create workspace if it doesn't exist
if [ ! -d "$TELLO_DRIVER_DIR/src" ]; then
    mkdir -p "$TELLO_DRIVER_DIR/src"
    check_error "Failed to create directory $TELLO_DRIVER_DIR/src"
fi

# Instalação otimizada dos pacotes do sistema
echo "Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y \
    ros-${ROS_DISTRO}-codec-image-transport \
    python3-catkin-tools \
    python3-dev \
    python3-pip \
    ros-${ROS_DISTRO}-image-transport \
    ros-${ROS_DISTRO}-teleop-twist-keyboard \
    libx264-dev \
    build-essential \
    ffmpeg \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    python3-rospkg \
    python3-rospy \
    python3-yaml \
    python3-empy \
    python3-numpy
check_error "Failed to install system dependencies"

# Install Python dependencies globally
echo "Installing Python dependencies..."
python3 -m pip install --upgrade pip
check_error "Failed to upgrade pip"
pip3 install djitellopy av
check_error "Failed to install DJITelloPy and PyAV"

cd "$TELLO_DRIVER_DIR/src" || check_error "Failed to change to $TELLO_DRIVER_DIR/src"
if [ ! -d "tello-driver-ros" ]; then
    git clone --recursive https://github.com/ACFR-RPG/tello-driver-ros.git
    check_error "Failed to clone tello-driver-ros (ACFR-RPG)"
fi
if [ ! -d "camera_info_manager_py" ]; then
    git clone --recursive https://github.com/ACFR-RPG/camera_info_manager_py.git
    check_error "Failed to clone camera_info_manager_py"
fi
if [ ! -d "h264_image_transport" ]; then
    git clone --recursive https://github.com/tilk/h264_image_transport/tree/master
    check_error "Failed to clone h264_image_transport"
fi
find . -type f -exec sed -i -E '1s|^#![ ]*/usr/bin/env python(2)?( .*)?$|#!/usr/bin/env python3\2|' {} +
find . -type f -name '*.cpp' -exec sed -i '/int len = avcodec_decode_video2(c, picture, &got_picture, &avpkt);/{
    c\
    int ret = avcodec_send_packet(c, &avpkt);\
    if (ret < 0) {\
        ROS_ERROR("Error sending packet for decoding");\
        return;\
    }\
    ret = avcodec_receive_frame(c, picture);\
    if (ret < 0) {\
        ROS_ERROR("Error during decoding");\
        return;\
    }
}' {} +
find . -type f -name '*.cpp' -exec sed -i '/if (len < 0 || !got_picture) {/,/}/d' {} +
find . -type f -name '*.cpp' -exec sed -i '/avcodec_register_all();/d' {} +
find . -type f -name '*.py' -exec sed -i 's|if (val1 & 0xff) is not 0:|if (val1 \& 0xff) != 0:|' {} +

# Update rosdep
echo "Updating rosdep..."
if ! [ -d "/etc/ros/rosdep" ]; then
    sudo rosdep init
    check_error "Failed to initialize rosdep"
else
    echo "rosdep already initialized"
fi
rosdep update
check_error "Failed to update rosdep"

# Initialize and build the workspace with catkin-tools
echo "Building workspace..."
cd "$TELLO_DRIVER_DIR" || check_error "Failed to change to $TELLO_DRIVER_DIR"
catkin config --init
check_error "Failed to initialize catkin workspace"
catkin build
check_error "Failed to build workspace"

echo "Configuring .bashrc..."
SOURCE_CMD="source $TELLO_DRIVER_DIR/devel/setup.bash"
PYTHONPATH_CMD="export PYTHONPATH=\$PYTHONPATH:$TELLO_DRIVER_DIR/devel/lib/python3/dist-packages"
if ! grep -Fx "$SOURCE_CMD" ~/.bashrc; then
    echo "$SOURCE_CMD" >> ~/.bashrc
fi
if [ -d "$TELLO_DRIVER_DIR/devel/lib/python3/dist-packages" ] && ! grep -Fx "$PYTHONPATH_CMD" ~/.bashrc; then
    echo "$PYTHONPATH_CMD" >> ~/.bashrc
fi
source "$TELLO_DRIVER_DIR/devel/setup.bash"
check_error "Failed to source workspace setup"

sudo usermod -a -G dialout "$USER"
