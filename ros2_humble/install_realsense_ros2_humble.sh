#!/usr/bin/env bash
set -euo pipefail

export CMAKE_SUPPRESS_DEVELOPER_WARNINGS=ON
export CMAKE_POLICY_DEFAULT_CMP0054=NEW
export CMAKE_ARGS="-DCMAKE_POLICY_VERSION_MINIMUM=3.10"
export CMAKE_POLICY_VERSION_MINIMUM=3.10

# Install RealSense
sudo mkdir -p /etc/apt/keyrings
curl -sSf https://librealsense.intel.com/Debian/librealsense.pgp | sudo tee /etc/apt/keyrings/librealsense.pgp > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/librealsense.pgp] https://librealsense.intel.com/Debian/apt-repo `lsb_release -cs` main" | \
sudo tee /etc/apt/sources.list.d/librealsense.list
sudo apt-get update
sudo apt-get install -y build-essential libusb-1.0-0-dev libudev-dev pkg-config libglfw3-dev python3-rosdep v4l-utils libssl-dev libgtk-3-dev libgl1-mesa-dev libglu1-mesa-dev qtbase5-dev libqt5opengl5-dev qt6-base-dev ros-humble-rosidl-typesupport-c
pip3 install -U PyQt6 pyrealsense2
cd "$HOME"
if [ ! -d "librealsense" ]; then
    git clone -b v2.51.1 https://github.com/IntelRealSense/librealsense.git --recursive
fi
cd librealsense
sudo ./scripts/setup_udev_rules.sh
if [ -d "build" ]; then
    rm -rf build
fi
mkdir build
cd build
cmake ../ -DFORCE_RSUSB_BACKEND=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=ON -DBUILD_GRAPHICAL_EXAMPLES=ON -DBUILD_PC_STITCHING=ON -DBUILD_GLSL_EXTENSIONS=ON -DBUILD_WITH_DDS=ON -DBUILD_UNIT_TESTS=ON -DBUILD_RS2_ALL=ON -DIMPORT_DEPTH_CAM_FW=ON -Wno-dev
make clean
make -j"$(nproc)"
sudo make install

cd "$HOME/px4_ws/src"
if [ ! -d "realsense-ros" ]; then
    git clone -b 4.51.1 https://github.com/IntelRealSense/realsense-ros.git --recursive
fi
cd "$HOME/px4_ws"
source /opt/ros/humble/setup.bash
if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
    sudo rosdep init
fi
rosdep update
rosdep install -i --from-path src --rosdistro $ROS_DISTRO --skip-keys=librealsense2 -y
source /opt/ros/humble/setup.bash
colcon build --cmake-args '-Wno-dev -DCMAKE_POLICY_VERSION_MINIMUM=3.10 -DBUILD_ACCELERATE_GPU_WITH_GLSL=ON'
source "$HOME/px4_ws/install/setup.bash"

gnome-terminal -- bash -c "realsense-viewer"
ros2 launch realsense2_camera rs_launch.py camera_name:=t265 accelerate_gpu_with_glsl:=true
