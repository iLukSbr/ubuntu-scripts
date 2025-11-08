#!/usr/bin/env bash
set -eo pipefail

locale  # check for UTF-8

sudo apt-get update
sudo apt-get install locales
sudo locale-gen pt_BR pt_BR.UTF-8
sudo update-locale LC_ALL=pt_BR.UTF-8 LANG=pt_BR.UTF-8
export LANG=pt_BR.UTF-8

locale  # verify settings

sudo apt-get install software-properties-common -y
sudo add-apt-repository universe -y
sudo apt-get update
sudo apt-get install curl lsb-release gnupg libssl-dev -y
ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}')
export ROS_APT_SOURCE_VERSION
curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
sudo dpkg -i /tmp/ros2-apt-source.deb
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y ros-dev-tools \
    freeglut3 ignition-transport11-cli libasound2-dev libdbus-1-dev libdecor-0-dev libdouble-conversion-dev libdrm-dev libegl1-mesa-dev libflann-dev libflann1.9 libfontconfig-dev libfontconfig1-dev libgbm-dev libgl2ps-dev libhdf5-mpi-dev libhdf5-openmpi-103-1 libhdf5-openmpi-cpp-103-1 \
    libhdf5-openmpi-dev libhdf5-openmpi-fortran-102 libhdf5-openmpi-hl-100 libhdf5-openmpi-hl-cpp-100 libhdf5-openmpi-hl-fortran-100 libibus-1.0-dev libignition-common4 libignition-common4-av libignition-common4-av-dev libignition-common4-core-dev libignition-common4-dev \
    libignition-common4-events libignition-common4-events-dev libignition-common4-graphics libignition-common4-graphics-dev libignition-common4-profiler libignition-common4-profiler-dev libignition-fuel-tools7 libignition-fuel-tools7-dev libignition-gazebo6 libignition-gazebo6-dev \
    libignition-gazebo6-plugins libignition-gui6 libignition-gui6-dev libignition-math6-eigen3-dev libignition-msgs8 libignition-msgs8-dev libignition-physics5 libignition-physics5-bullet libignition-physics5-bullet-dev libignition-physics5-core-dev libignition-physics5-dartsim \
    libignition-physics5-dartsim-dev libignition-physics5-dev libignition-physics5-heightmap-dev libignition-physics5-mesh-dev libignition-physics5-sdf-dev libignition-physics5-tpe libignition-physics5-tpe-dev libignition-physics5-tpelib libignition-physics5-tpelib-dev libignition-plugin \
    libignition-plugin-dev libignition-rendering6 libignition-rendering6-core-dev libignition-rendering6-dev libignition-rendering6-ogre1 libignition-rendering6-ogre1-dev libignition-rendering6-ogre2 libignition-rendering6-ogre2-dev libignition-sensors6 libignition-sensors6-air-pressure \
    libignition-sensors6-air-pressure-dev libignition-sensors6-altimeter libignition-sensors6-altimeter-dev libignition-sensors6-boundingbox-camera libignition-sensors6-boundingbox-camera-dev libignition-sensors6-camera libignition-sensors6-camera-dev libignition-sensors6-core-dev \
    libignition-sensors6-depth-camera libignition-sensors6-depth-camera-dev libignition-sensors6-dev libignition-sensors6-force-torque libignition-sensors6-force-torque-dev libignition-sensors6-gpu-lidar libignition-sensors6-gpu-lidar-dev libignition-sensors6-imu libignition-sensors6-imu-dev \
    libignition-sensors6-lidar libignition-sensors6-lidar-dev libignition-sensors6-logical-camera libignition-sensors6-logical-camera-dev libignition-sensors6-magnetometer libignition-sensors6-magnetometer-dev libignition-sensors6-navsat libignition-sensors6-navsat-dev \
    libignition-sensors6-rendering libignition-sensors6-rendering-dev libignition-sensors6-rgbd-camera libignition-sensors6-rgbd-camera-dev libignition-sensors6-segmentation-camera libignition-sensors6-segmentation-camera-dev libignition-sensors6-thermal-camera \
    libignition-sensors6-thermal-camera-dev libignition-transport11 libignition-transport11-core-dev libignition-transport11-dev libignition-transport11-log libignition-transport11-log-dev libignition-transport11-parameters libignition-transport11-parameters-dev libignition-utils1-cli-dev \
    libnetcdf-c++4 libnetcdf-cxx-legacy-dev libogre-next-dev libogrenexthlmspbs2.2.5 libogrenexthlmsunlit2.2.5 libogrenextmain2.2.5 libogrenextmeshlodgenerator2.2.5 libogrenextoverlay2.2.5 libogrenextplanarreflections2.2.5 libogrenextsceneformat2.2.5 libopenni-dev libopenni-sensor-pointclouds0 \
    libopenni0 libopenni2-0 libopenni2-dev libpciaccess-dev libpcl-apps1.12 libpcl-common1.12 libpcl-dev libpcl-features1.12 libpcl-filters1.12 libpcl-io1.12 libpcl-kdtree1.12 libpcl-keypoints1.12 libpcl-ml1.12 libpcl-octree1.12 libpcl-outofcore1.12 libpcl-people1.12 libpcl-recognition1.12 \
    libpcl-registration1.12 libpcl-sample-consensus1.12 libpcl-search1.12 libpcl-segmentation1.12 libpcl-stereo1.12 libpcl-surface1.12 libpcl-tracking1.12 libpcl-visualization1.12 libpulse-dev libqt5designercomponents5 libqt5location5 libqt5location5-plugins libqt5positioning5 \
    libqt5positioning5-plugins libqt5positioningquick5 libqt5sensors5 libqt5webchannel5 libqt5webkit5 libqt5webkit5-dev libsdl2-dev libsndio-dev libudev-dev libusb-1.0-0-dev libusb-1.0-doc libutfcpp-dev libvtk9-dev libvtk9-java libvtk9-qt-dev libvtk9.1-qt libwayland-bin libwayland-dev \
    libxcursor-dev libxfixes-dev libxft-dev libxi-dev libxinerama-dev libxkbcommon-dev libxss-dev libxv-dev libxxf86vm-dev openni-utils pydocstyle pyflakes3 python3-flake8 python3-mccabe python3-mpi4py python3-psutil python3-pycodestyle python3-pydocstyle python3-pydot python3-pyflakes \
    python3-pykdl python3-semver python3-snowballstemmer python3-vtk9 qdoc-qt5 qhelpgenerator-qt5 qml-module-qtlocation qml-module-qtpositioning qt5-assistant qtattributionsscanner-qt5 qttools5-dev qttools5-dev-tools qttools5-private-dev ros-humble-action-tutorials-cpp \
    ros-humble-action-tutorials-interfaces ros-humble-action-tutorials-py ros-humble-actionlib-msgs ros-humble-ament-cmake-auto ros-humble-ament-cmake-copyright ros-humble-ament-cmake-cppcheck ros-humble-ament-cmake-cpplint ros-humble-ament-cmake-flake8 ros-humble-ament-cmake-lint-cmake \
    ros-humble-ament-cmake-pep257 ros-humble-ament-cmake-uncrustify ros-humble-ament-cmake-xmllint ros-humble-ament-copyright ros-humble-ament-cppcheck ros-humble-ament-cpplint ros-humble-ament-flake8 ros-humble-ament-lint ros-humble-ament-lint-auto ros-humble-ament-lint-cmake \
    ros-humble-ament-lint-common ros-humble-ament-pep257 ros-humble-ament-uncrustify ros-humble-ament-xmllint ros-humble-angles ros-humble-camera-calibration ros-humble-camera-calibration-parsers ros-humble-camera-info-manager ros-humble-common-interfaces ros-humble-composition \
    ros-humble-demo-nodes-cpp ros-humble-demo-nodes-cpp-native ros-humble-demo-nodes-py ros-humble-depth-image-proc ros-humble-depthimage-to-laserscan ros-humble-desktop ros-humble-diagnostic-msgs ros-humble-diagnostic-updater ros-humble-dummy-map-server ros-humble-dummy-robot-bringup \
    ros-humble-dummy-sensors ros-humble-example-interfaces ros-humble-examples-rclcpp-minimal-action-client ros-humble-examples-rclcpp-minimal-action-server ros-humble-examples-rclcpp-minimal-client ros-humble-examples-rclcpp-minimal-composition ros-humble-examples-rclcpp-minimal-publisher \
    ros-humble-examples-rclcpp-minimal-service ros-humble-examples-rclcpp-minimal-subscriber ros-humble-examples-rclcpp-minimal-timer ros-humble-examples-rclcpp-multithreaded-executor ros-humble-examples-rclpy-executors ros-humble-examples-rclpy-minimal-action-client \
    ros-humble-examples-rclpy-minimal-action-server ros-humble-examples-rclpy-minimal-client ros-humble-examples-rclpy-minimal-publisher ros-humble-examples-rclpy-minimal-service ros-humble-examples-rclpy-minimal-subscriber ros-humble-filters ros-humble-geometry2 ros-humble-gps-msgs \
    ros-humble-image-common ros-humble-image-geometry ros-humble-image-pipeline ros-humble-image-proc ros-humble-image-publisher ros-humble-image-rotate ros-humble-image-tools ros-humble-image-view ros-humble-intra-process-demo ros-humble-joy ros-humble-laser-filters ros-humble-launch-ros \
    ros-humble-launch-testing-ros ros-humble-lifecycle ros-humble-logging-demo ros-humble-pcl-conversions ros-humble-pcl-msgs ros-humble-pcl-ros ros-humble-pendulum-control ros-humble-pendulum-msgs ros-humble-perception ros-humble-perception-pcl ros-humble-python-orocos-kdl-vendor \
    ros-humble-qt-dotgraph ros-humble-quality-of-service-demo-cpp ros-humble-quality-of-service-demo-py ros-humble-rclcpp-lifecycle ros-humble-ros-base ros-humble-ros-core ros-humble-ros-environment ros-humble-ros2action ros-humble-ros2cli-common-extensions ros-humble-ros2component \
    ros-humble-ros2doctor ros-humble-ros2interface ros-humble-ros2launch ros-humble-ros2lifecycle ros-humble-ros2multicast ros-humble-ros2node ros-humble-ros2param ros-humble-ros2pkg ros-humble-ros2run ros-humble-ros2service ros-humble-ros2topic ros-humble-rosbag2 \
    ros-humble-rosbag2-compression-zstd ros-humble-rosbag2-storage-default-plugins ros-humble-rosidl-default-generators ros-humble-rosidl-runtime-py ros-humble-rqt-action ros-humble-rqt-bag ros-humble-rqt-bag-plugins ros-humble-rqt-common-plugins ros-humble-rqt-console ros-humble-rqt-graph \
    ros-humble-rqt-msg ros-humble-rqt-publisher ros-humble-rqt-py-console ros-humble-rqt-reconfigure ros-humble-rqt-service-caller ros-humble-rqt-shell ros-humble-rqt-srv ros-humble-rttest ros-humble-sdl2-vendor ros-humble-shape-msgs ros-humble-sqlite3-vendor ros-humble-sros2 \
    ros-humble-sros2-cmake ros-humble-std-srvs ros-humble-stereo-image-proc ros-humble-stereo-msgs ros-humble-teleop-twist-joy ros-humble-teleop-twist-keyboard ros-humble-tf2-bullet ros-humble-tf2-eigen ros-humble-tf2-eigen-kdl ros-humble-tf2-kdl ros-humble-tf2-sensor-msgs ros-humble-tf2-tools \
    ros-humble-tlsf ros-humble-tlsf-cpp ros-humble-topic-monitor ros-humble-tracetools-image-pipeline ros-humble-turtlesim ros-humble-uncrustify-vendor ros-humble-vision-opencv ros-humble-zstd-vendor tcl-dev tcl8.6-dev tk-dev tk8.6-dev uncrustify vtk9 \
    mingw-w64 libgflags-dev libgflags2.2 ros-humble-actuator-msgs ros-humble-sdformat-urdf ros-humble-vision-msgs ros-humble-xacro \
    ros-humble-desktop ros-humble-perception ros-humble-ros-workspace vim

# Add ROS Humble setup to bashrc if not already present
declare -a ROS_VARS=(
    'export PYTHONPATH="/opt/ros/humble/lib/python3.10/dist-packages${PYTHONPATH:+:${PYTHONPATH}}"'
    'source /opt/ros/humble/setup.bash'
)

ADDED=false
for var in "${ROS_VARS[@]}"; do
    if ! grep -qF "$var" "$HOME/.bashrc"; then
        echo "$var" >> "$HOME/.bashrc"
        ADDED=true
    fi
done

if $ADDED; then
    echo "ROS Humble setup added to $HOME/.bashrc"
else
    echo "ROS Humble setup already in $HOME/.bashrc"
fi

# Install Gazebo Harmonic
sudo curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] https://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install gz-harmonic ros-humble-ros-gzharmonic -y

# Install ROS 2 build tools and other dependencies
sudo apt-get install -y \
    python3-colcon-common-extensions \
    python3-colcon-mixin \
    python3-rosdep \
    python3-vcstool \
    ros-humble-launch-testing-ament-cmake \
    ros-humble-ros2bag \
    ros-humble-rosidl-generator-dds-idl \
    ros-humble-eigen3-cmake-module \
    bzip2 ca-certificates ccache cmake cppcheck dirmngr doxygen file g++ gcc gdb git gnupg lcov \
    libfreetype6-dev libgtest-dev libpng-dev libssl-dev lsb-release make ninja-build openjdk-11-jdk \
    openjdk-11-jre libvecmath-java openssh-client pkg-config python3-dev python3-pip rsync shellcheck \
    tzdata unzip valgrind wget xsltproc zip gedit bash-completion command-not-found libgtest-dev \
    astyle jq libopencv-dev libopencv-contrib-dev doxygen python3-rosdoc2 python3-sphinx python3-sphinx-rtd-theme python3-breathe python3-exhale

# Install additional Python packages
python3 -m pip install --upgrade pip
pip3 install -U \
    argcomplete \
    flake8 \
    flake8-blind-except \
    flake8-builtins \
    flake8-class-newline \
    flake8-comprehensions \
    flake8-deprecated \
    flake8-docstrings \
    flake8-import-order \
    flake8-quotes \
    pytest-repeat \
    pytest-rerunfailures \
    empy==3.3.4 pyros-genmsg setuptools==65.5.1 argparse argcomplete coverage cerberus jinja2 kconfiglib matplotlib numpy nunavut packaging pkgconfig pyulog pyyaml requests serial six toml psutil pyulog wheel jsonschema pynacl
