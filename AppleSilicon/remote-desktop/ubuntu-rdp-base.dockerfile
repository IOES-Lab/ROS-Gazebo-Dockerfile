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

EXPOSE 3389/tcp
EXPOSE 22/tcp
CMD sudo rm -f /var/run/xrdp/xrdp*.pid >/dev/null 2>&1; \
    sudo service dbus restart >/dev/null 2>&1; \
    sudo /usr/lib/systemd/systemd-logind >/dev/null 2>&1 & \
    [ -f /usr/sbin/sshd ] && sudo /usr/sbin/sshd; \
    sudo xrdp-sesman --config /etc/xrdp/sesman.ini; \
    sudo xrdp --nodaemon --config /etc/xrdp/xrdp.ini

# Down to here is at woensugchoi/ubuntu-arm-rdp
# docker build -t ubuntu-rdp -f ubuntu-rdp.dockerfile .
# docker run -it -p 3389:3389 -p 22:22 ubuntu-rdp
# Connect with RDP client (https://apps.apple.com/kr/app/microsoft-remote-desktop/id1295203466) to localhost