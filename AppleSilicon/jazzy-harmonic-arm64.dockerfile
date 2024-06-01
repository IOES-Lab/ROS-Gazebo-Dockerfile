# FOR APPLE SILICON (I.E. M1 MACBOOK) !!
# FOR APPLE SILICON (I.E. M1 MACBOOK) !!
# FOR APPLE SILICON (I.E. M1 MACBOOK) !!
# ==================================== #
# ========    ROS & GAZEBO    ======== #
# ==================================== #
# --------      Versions      -------- #
# Ubuntu : 24.04
# ROS : Jazzy
# Gazebo : Harmonic
# ------------------------------------ #
# To Build
# docker build -t jazzy-harmonic -f jazzy-harmonic-arm64.dockerfile .
# To Run
# docker run --rm -it --privileged jazzy-harmonic

# Starting from ubuntu 24.04
FROM arm64v8/ubuntu:24.04

# Change apt repo to ones in South Korea
# RUN sed -i 's/archive.ubuntu.com/ftp.kaist.ac.kr/g' /etc/apt/sources.list

# update and upgrade libs
RUN apt update \
    && apt-get -y upgrade \
    && rm -rf /tmp/*

# Install basics 
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
RUN truncate -s0 /tmp/preseed.cfg && \
   (echo "tzdata tzdata/Areas select Asia" >> /tmp/preseed.cfg) && \
   (echo "tzdata tzdata/Zones/Asia select Seoul" >> /tmp/preseed.cfg) && \
   debconf-set-selections /tmp/preseed.cfg && \
   rm -f /etc/timezone && \
   apt-get install -y sudo tzdata build-essential gfortran automake \
   bison flex libtool git wget software-properties-common
## cleanup of files from setup
RUN rm -rf /tmp/*

# Install Utilities
RUN apt-get -y install x11-apps mesa-utils xauth \
    && rm -rf /tmp/*

# --------   ROS INSTALLATION   -------- #
# Locale for UTF-8
RUN apt-get -y install locales \
    && rm -rf /tmp/*
RUN locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    export LANG=en_US.UTF-8

# Set source codes
RUN apt-get -y install software-properties-common && \
    add-apt-repository universe && \
    rm -rf /tmp/*
RUN apt-get update && apt-get -y install curl && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    rm -rf /tmp/*
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
    apt-get update && apt-get -y upgrade && rm -rf /tmp/*

# Install ROS 2 Package
RUN apt-get -y install ros-jazzy-desktop-full ros-dev-tools ros-jazzy-ros-gz
RUN echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc

# --------   GAZEBO INSTALLATION   -------- #
# Install dependency packages
RUN apt-get -y install python3-pip lsb-release gnupg curl git && \
    rm -rf /tmp/*

# Install dependency libraries
RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list >/dev/null && \
    apt-get update && apt-get -y upgrade && rm -rf /tmp/*

# Install Gazebo Harmonic binary
RUN apt -y install gz-harmonic

# ------------ SET-UP A USER ------------- #
# Make user (assume host user has 1000:1000 permission)
RUN adduser --shell /bin/bash --disabled-password --gecos "" user \
    && echo 'user:user' | chpasswd && adduser user sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# Set User as user
USER user

# Use software rendering for container
ENV LIBGL_ALWAYS_INDIRECT=1

# Local setting for UTF-8
ENV LANG=en_US.UTF-8

# Set-up ROS Environment as default
RUN echo "" >> ~/.bashrc && \
    echo "# Set ROS Environment alive" >> ~/.bashrc && \
    echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc

# Set-up Gazebo Environment as default
# RUN echo "" >> ~/.bashrc && \
#     echo "# Automatic set-up of the Gazebo in /gazebo" >> ~/.bashrc && \
#     echo "source /gazebo/install/setup.bash" >> ~/.bashrc

# To Build
# docker build -t jazzy-harmonic -f jazzy-harmonic-arm64.dockerfile .
# To Run
# docker run --rm -it --privileged jazzy-harmonic