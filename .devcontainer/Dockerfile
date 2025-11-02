# Docker image for VS Code development

# ROS Noetic Desktop Full base image
FROM osrf/ros:noetic-desktop-full

# Define the maintainer
LABEL maintainer="lesc-utfpr@gmail.com"

# Install basic dependencies
RUN apt-get update && apt-get install -y \
        software-properties-common \
        apt-transport-https \
        wget \
        curl \
        git \
        xauth \
        python3-pip \
        python3-rosdep \
        python3-catkin-tools \
        python3-empy \
        python3-dev \
        build-essential \
        libssl-dev \
        doxygen && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

# Install PowerShell and .NET SDK
ADD https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb /tmp/packages-microsoft-prod.deb
RUN dpkg -i /tmp/packages-microsoft-prod.deb && \
    rm /tmp/packages-microsoft-prod.deb && \
    add-apt-repository universe && \
    apt-get update && \
    apt-get install -y \
        powershell \
        dotnet-sdk-8.0 \
        aspnetcore-runtime-8.0 && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash && \
    \. "$HOME/.nvm/nvm.sh" && \
    nvm install 22

# Add ROS repository
RUN rm -f /etc/apt/sources.list.d/ros-latest.list && \
    rm -f /etc/apt/sources.list.d/ros1-latest.list && \
    sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
    apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 && \
    apt-get update && \
    apt-get install -y \
        ros-noetic-desktop-full && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt /root/requirements.txt

RUN pip install -r /root/requirements.txt && \
    rm -f /root/requirements.txt

# Clean up apt-get
RUN apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove -y  && \
    rm -rf /var/lib/apt/lists/*

# Create bashrc
RUN echo 'export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus' >> /root/.bashrc && \
    echo 'export XDG_RUNTIME_DIR=/tmp' >> /root/.bashrc && \
    echo 'mkdir -p /tmp/runtime-root' >> /root/.bashrc && \
    echo 'chmod 700 /tmp/runtime-root' >> /root/.bashrc && \
    echo 'export XAUTHORITY=/tmp/.docker.xauth' >> /root/.bashrc && \
    echo 'touch $XAUTHORITY' >> /root/.bashrc && \
    echo 'if [ -n "$DISPLAY" ]; then' >> /root/.bashrc && \
    echo '    xauth nlist $DISPLAY | sed -e "s/^..../ffff/" | xauth -f $XAUTHORITY nmerge - || echo "Warning: Failed to generate xauth entries"' >> /root/.bashrc && \
    echo 'else' >> /root/.bashrc && \
    echo '    echo "Warning: DISPLAY environment variable is not set. X11 forwarding may not work."' >> /root/.bashrc && \
    echo 'fi' >> /root/.bashrc && \
    echo 'if [ -f "/opt/ros/noetic/setup.bash" ]; then source /opt/ros/noetic/setup.bash; fi' >> /root/.bashrc && \
    echo 'if [ -f "/root/catkin_ws/devel/setup.bash" ]; then source /root/catkin_ws/devel/setup.bash; fi' >> /root/.bashrc

# Copy the entrypoint script into the container
COPY .devcontainer/ros_entrypoint.sh /ros_entrypoint.sh

EXPOSE 11311

# Make the script executable
RUN chmod +x /ros_entrypoint.sh

# Set the entrypoint for ROS
ENTRYPOINT ["/ros_entrypoint.sh"]
