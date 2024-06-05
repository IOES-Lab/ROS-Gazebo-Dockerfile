FROM arm64v8/ubuntu:24.04
RUN apt update -y && apt install --no-install-recommends -y -q \
    ubuntu-desktop-minimal \
    && rm -rf /var/lib/apt/lists/*

RUN truncate -s0 /tmp/preseed.cfg && \
   (echo "tzdata tzdata/Areas select Etc" >> /tmp/preseed.cfg) && \
   (echo "tzdata tzdata/Zones/Etc select UTC" >> /tmp/preseed.cfg) && \
   debconf-set-selections /tmp/preseed.cfg && \
   rm -f /etc/timezone && \
   dpkg-reconfigure -f noninteractive tzdata
# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get -y install --no-install-recommends locales tzdata \
    && rm -rf /tmp/*
RUN locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    export LANG=en_US.UTF-8

# Install basic packages
RUN apt update -y && apt install --no-install-recommends -y -q \
    sudo \
    xterm \
    init \
    systemd \
    snapd \
    vim \
    net-tools \
    curl \
    wget \
    git \
    tzdata \
    build-essential \
    cmake \
    cppcheck \
    gnupg \
    libeigen3-dev \
    libgles2-mesa-dev \
    lsb-release \
    pkg-config \
    protobuf-compiler \
    python3-dbg \
    python3-pip \
    python3-venv \
    qtbase5-dev \
    ruby \
    software-properties-common \
    x11-apps mesa-utils \
    dirmngr \
    gnupg2 \
    nano \
    htop \
    && rm -rf /var/lib/apt/lists/*

