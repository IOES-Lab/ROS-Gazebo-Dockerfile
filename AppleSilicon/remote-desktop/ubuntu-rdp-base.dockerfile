FROM arm64v8/ubuntu:24.04
# Set RDP and SSH environments
# access with any RDP client at localhost:3389 with USER/PASS)
# SSh connect and forward X11 with USER/PASS at localhost:22
ARG X11Forwarding=true
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
        apt-get install -y ubuntu-desktop-minimal dbus-x11 xrdp sudo; \
    [ $X11Forwarding = 'true' ] && apt-get install -y openssh-server; \
    apt-get autoremove --purge; \
    apt-get clean; \
    rm /run/reboot-required*

# Down to here is at woensugchoi/ubuntu-arm-rdp-base

ARG USER=docker
ARG PASS=docker

RUN useradd -s /bin/bash -m $USER -p $(openssl passwd "$PASS"); \
    usermod -aG sudo $USER; echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers; \
    adduser xrdp ssl-cert; \
    # Setting the required environment variables
    echo 'LANG=en_US.UTF-8' >> /etc/default/locale; \
    echo 'export GNOME_SHELL_SESSION_MODE=ubuntu' > /home/$USER/.xsessionrc; \
    echo 'export XDG_CURRENT_DESKTOP=ubuntu:GNOME' >> /home/$USER/.xsessionrc; \
    echo 'export XDG_SESSION_TYPE=x11' >> /home/$USER/.xsessionrc; \
    # Enabling log to the stdout
    sed -i "s/#EnableConsole=false/EnableConsole=true/g" /etc/xrdp/xrdp.ini; \
    # Disabling system animations and reducing the
    # image quality to improve the performance
    sed -i 's/max_bpp=32/max_bpp=16/g' /etc/xrdp/xrdp.ini; \
    gsettings set org.gnome.desktop.interface enable-animations true; \
    # Listening on wildcard address for X forwarding
    [ $X11Forwarding = 'true' ] && \
        sed -i 's/#X11UseLocalhost yes/X11UseLocalhost no/g' /etc/ssh/sshd_config || \
        sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config || \
        :;

# Disable initial welcome window
RUN echo "X-GNOME-Autostart-enabled=false" >> /etc/xdg/autostart/gnome-initial-setup-first-login.desktop

# Install basics
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo xterm init systemd snapd vim net-tools \
    curl wget git build-essential cmake cppcheck \
    gnupg libeigen3-dev libgles2-mesa-dev \
    lsb-release pkg-config protobuf-compiler \
    python3-dbg python3-pip python3-venv \
    qtbase5-dev ruby dirmngr gnupg2 nano xauth \
    software-properties-common htop libtool \
    x11-apps mesa-utils bison flex automake && \
    rm -rf /var/lib/apt/lists/

# Locale for UTF-8
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

EXPOSE 3389/tcp
EXPOSE 22/tcp
CMD sudo rm -f /var/run/xrdp/xrdp*.pid >/dev/null 2>&1; \
    sudo service dbus restart >/dev/null 2>&1; \
    sudo /usr/lib/systemd/systemd-logind >/dev/null 2>&1 & \
    [ -f /usr/sbin/sshd ] && sudo /usr/sbin/sshd; \
    sudo xrdp-sesman --config /etc/xrdp/sesman.ini; \
    sudo xrdp --nodaemon --config /etc/xrdp/xrdp.ini

## ---- FOR FATSTER COMPILE FOR DAVE ARM64 ---- #

# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get -y install --no-install-recommends  \
    mercurial-common mercurial gfortran-13 python3.12-dev \
    freeglut3-dev mysql-common javascript-common isympy-common \
    unixodbc-common openmpi-common libzvbi-common openmpi-bin \
    graphviz gfortran mpi-default-dev \
    && rm -rf /tmp/*

# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get -y install --no-install-recommends  \
    python3-cssselect python3-more-itertools python3-iniconfig python3-lark python3-lz4 \
    python3-fastbencode python3-unicodedata2 python3-pyflakes python3-typeguard \
    python3-fastimport python3-coverage python3-distlib python3-zipp python3-empy \
    python3-webencodings python3-psutil python3-roman python3-decorator python3-pycodestyle \
    python3-packaging python3-merge3 python3-gpg python3-snowballstemmer python3-brotli \
    python3-cycler python3-wrapt python3-typing-extensions python3-html5lib python3-pluggy \
    python3-patiencediff python3-pyqt5.sip python3-notify2 python3-dulwich python3-lxml:arm64 \
    python3-pydocstyle python3-mccabe python3-protobuf python3-mpmath python3-tzlocal \
    python3-argcomplete python3-appdirs python3-soupsieve python3-deprecated python3-nacl \
    python3-pyqt5 python3-sip python3-pyqt5.qtsvg python3-sympy python3-flake8-import-order \
    python3-importlib-metadata python3-pytest python3-breezy python3-bs4 \
    python3-colcon-notification python3-colcon-pkg-config python3-github \
    python3-colcon-library-path python3-flake8-quotes python3-colcon-argcomplete \
    python3-numpy python3-pyside2.qtcore python3-colcon-core python3-fs python3-flake8 \
    python3-colcon-output python3-colcon-package-selection python3-pydot \
    python3-colcon-devtools python3-colcon-test-result python3-scipy python3-pyside2.qtgui \
    python3-flake8-comprehensions python3-tk:arm64 python3-pytest-cov \
    python3-flake8-builtins python3-colcon-recursive-crawl python3-pyproj \
    python3-pil.imagetk:arm64 python3-dev python3-colcon-cd \
    python3-pybind11 python3-pyside2.qtsvg python3-sip-dev \
    python3-opencv:arm64 python3-fonttools python3-ufolib2 python3-matplotlib \
    python3-docutils python3-catkin-pkg python3-colcon-ros \
    && rm -rf /tmp/*

# Down to here is at woensugchoi/ubuntu-arm-rdp
# docker build -t ubuntu-rdp -f ubuntu-rdp.dockerfile .
# docker run -it -p 3389:3389 -p 22:22 ubuntu-rdp
# Connect with RDP client (https://apps.apple.com/kr/app/microsoft-remote-desktop/id1295203466) to localhost