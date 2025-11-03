#!/usr/bin/env bash
set -euo pipefail

export CMAKE_SUPPRESS_DEVELOPER_WARNINGS=ON
export CMAKE_POLICY_DEFAULT_CMP0054=NEW
export CMAKE_ARGS="-DCMAKE_POLICY_VERSION_MINIMUM=3.10"
export CMAKE_POLICY_VERSION_MINIMUM=3.10

# Disable FIPS repositories to avoid package conflicts
if ls /etc/apt/sources.list.d/*fips* 1> /dev/null 2>&1; then
    echo "Disabling FIPS repositories..."
    sudo rm /etc/apt/sources.list.d/*fips*
    sudo apt-get update -y
fi

# Force standard libgmp10 to avoid FIPS conflicts
if dpkg -l libgmp10 2>/dev/null | grep -q Fips; then
    echo "Forcing standard libgmp10 version..."
    cd /tmp
    sudo apt download libgmp10=2:6.2.1+dfsg-3ubuntu1
    sudo dpkg -i libgmp10_2%3a6.2.1+dfsg-3ubuntu1_amd64.deb
    rm libgmp10_2%3a6.2.1+dfsg-3ubuntu1_amd64.deb
fi

sudo apt-get install -y geographiclib-tools \
    libgeographic19 \
    libgeographic-dev \
    python3-geographiclib
sudo apt-get install gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good -y
sudo apt-get install libfuse2 -y
sudo apt-get install libxcb-xinerama0 libxkbcommon-x11-0 libxcb-cursor-dev -y

# Download and execute official GeographicLib dataset installer in /tmp
GEOLIB_SCRIPT="/tmp/install_geographiclib_datasets.sh"
if [ ! -f "$GEOLIB_SCRIPT" ]; then
    wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh -O "$GEOLIB_SCRIPT"
fi
sudo bash "$GEOLIB_SCRIPT"

cd "$HOME"
if [ ! -d "PX4-Autopilot" ]; then
    git clone -b v1.16.0 https://github.com/PX4/PX4-Autopilot.git --recursive
fi
cd PX4-Autopilot/
make distclean
find . -name "index.lock" -delete
git submodule update --init --recursive
if [ -d "build" ]; then
    rm -rf build
fi
mkdir -p build/px4_sitl_default
bash ./Tools/setup/ubuntu.sh
make px4_sitl

# Install Micro XRCE-DDS Agent (standalone build, no ROS workspace needed)
cd "$HOME"
if [ ! -d "Micro-XRCE-DDS-Agent" ]; then
    git clone -b v2.4.3 https://github.com/eProsima/Micro-XRCE-DDS-Agent.git
fi
cd Micro-XRCE-DDS-Agent
if [ -d "build" ]; then
    rm -rf build
fi
mkdir build
cd build
cmake .. -Wno-dev
make clean
make -j"$(nproc)"
sudo make install
sudo ldconfig /usr/local/lib/

# Enable serial-port access
sudo usermod -aG dialout "$(id -un)"

# Download and install QGroundControl AppImage
if [ -f "/usr/local/bin/qgroundcontrol" ]; then
    if [ -f "$HOME/QGroundControl.AppImage" ]; then
        rm -f "$HOME/QGroundControl.AppImage"
    fi
    wget https://github.com/mavlink/qgroundcontrol/releases/download/v5.0.8/QGroundControl-x86_64.AppImage -O "$HOME/QGroundControl.AppImage"
    sudo chmod +x "$HOME/QGroundControl.AppImage"
    sudo mv "$HOME/QGroundControl.AppImage" /usr/local/bin/qgroundcontrol
    sudo chmod +x /usr/local/bin/qgroundcontrol
fi

# Create desktop entry for application menu (if not exists)
if [ ! -f /usr/share/applications/qgroundcontrol.desktop ]; then
    cat <<EOF | sudo tee /usr/share/applications/qgroundcontrol.desktop
[Desktop Entry]
Name=QGroundControl
Exec=/usr/local/bin/qgroundcontrol
Icon=applications-system
Type=Application
Categories=Utility;Development;
EOF
    echo "Desktop entry created for QGroundControl"
else
    echo "Desktop entry for QGroundControl already exists"
fi

echo "QGroundControl permanently installed. To run: qgroundcontrol"

# Configure QGroundControl video source
QGC_CONFIG_DIR="$HOME/.config/QGroundControl"
mkdir -p "$QGC_CONFIG_DIR"
QGC_INI="$QGC_CONFIG_DIR/QGroundControl.ini"
touch "$QGC_INI"
if ! grep -q "\[Video\]" "$QGC_INI"; then
    echo "[Video]" >> "$QGC_INI"
    echo "videoSource=UDP h.264 Video Stream" >> "$QGC_INI"
fi

# Install PX4 ROS 2 messages
mkdir -p "$HOME/px4_ws/src"
cd "$HOME/px4_ws/src"
if [ ! -d "px4_msgs" ]; then
    git clone -b release/1.16 https://github.com/PX4/px4_msgs.git --recursive
fi
if [ ! -d "px4_ros_com" ]; then
    git clone -b release/1.16 https://github.com/PX4/px4_ros_com.git --recursive
fi
cd "$HOME/px4_ws"
export AMENT_PREFIX_PATH=""
export CMAKE_PREFIX_PATH=""
source /opt/ros/humble/setup.bash
colcon build --symlink-install --packages-select px4_msgs px4_ros_com --cmake-args -Wno-dev

if ! grep -qF 'source $HOME/px4_ws/install/setup.bash' "$HOME/.bashrc"; then
    echo 'source $HOME/px4_ws/install/setup.bash' >> "$HOME/.bashrc"
    echo "Added PX4 ROS2 workspace to ~/.bashrc"
else
    echo "PX4 ROS2 workspace already in ~/.bashrc"
fi
source /opt/ros/humble/setup.bash
source "$HOME/px4_ws/install/setup.bash"
cd "$HOME/PX4-Autopilot/"
gnome-terminal -- bash -c "ros2 launch px4_ros_com sensor_combined_listener.launch.py"
gnome-terminal -- bash -c "MicroXRCEAgent udp4 -p 8888"
gnome-terminal -- bash -c "qgroundcontrol"
export PX4_PARAM_MAV_0_BROADCAST=1
export PX4_SIM_LOCKSTEP=1
export PX4_GZ_WORLD=walls
make px4_sitl gz_x500_mono_cam
