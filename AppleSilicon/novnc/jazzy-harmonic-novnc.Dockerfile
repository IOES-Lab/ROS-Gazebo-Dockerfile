FROM ubuntu:noble
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update -y && apt install --no-install-recommends -y -q \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    novnc \
    websockify \
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
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    x11-apps mesa-utils \
    xubuntu-icon-theme \
    dirmngr \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*
RUN add-apt-repository ppa:mozillateam/ppa -y
RUN echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox
RUN echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox
RUN echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox
RUN echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:noble";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox
RUN apt update -y && apt install -y firefox

ENV LC_ALL=C.UTF-8
# RUN apt update && apt-get install -y locales
# RUN locale-gen ko_KR.UTF-8
# ENV LC_ALL ko_KR.UTF-8

# Korean input method
RUN apt update -y && apt install -y uim uim-byeoru fonts-nanum
ENV XIM=uim
ENV GTK_IM_MODULE=uim
ENV QT_IM_MODULE=uim
ENV XMODIFIERS=@im=uim
ENV UIM_CANDWIN_PROG=uim-candwin-gtk

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# setup sources.list
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list >/dev/null

ENV DIST jazzy
ENV GAZ gz-harmonic

# Install ROS-Gazebo
RUN apt update -y && apt install --no-install-recommends -y \
    ros-${DIST}-desktop-full \
    ros-${DIST}-ros-gz \
    && rm -rf /var/lib/apt/lists/*
# RUN apt update -y && apt install --no-install-recommends -y \
#     ${GAZ} \
#     && rm -rf /var/lib/apt/lists/*

# setup entrypoint
# COPY ./ros_entrypoint.sh /

# ENTRYPOINT ["/ros_entrypoint.sh"]

# RUN
RUN touch /root/.Xauthority
EXPOSE 5901
EXPOSE 6080
CMD bash -c "vncserver -localhost no -SecurityTypes None -geometry 1920x1080 --I-KNOW-THIS-IS-INSECURE && openssl req -new -subj "/C=KR" -x509 -days 365 -nodes -out self.pem -keyout self.pem && websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && tail -f /dev/null"

# docker build -f jazzy-harmonic-novnc.Dockerfile -t jazzy-harmonic-novnc .
# docker run -it -p 6080:6080 jazzy-harmonic-novnc
# http://localhost:6080/vnc.html