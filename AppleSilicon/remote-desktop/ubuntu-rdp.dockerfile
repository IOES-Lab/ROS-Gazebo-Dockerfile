FROM arm64v8/ubuntu:24.04
EXPOSE 3389/tcp
# EXPOSE 22/tcp
ARG USER=ioes
ARG PASS=ioes
ARG X11Forwarding=false

# Set RDP and SSH environments
# access with any RDP client at localhost:3389 with USER/PASS)
# SSh connect and forward X11 with USER/PASS at localhost:22

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
        apt-get install -y ubuntu-desktop-minimal=1.539 dbus-x11 xrdp sudo; \
    [ $X11Forwarding = 'true' ] && apt-get install -y openssh-server; \
    apt-get autoremove --purge; \
    apt-get clean; \
    rm /run/reboot-required*

RUN useradd -s /bin/bash -m $USER -p $(openssl passwd "$PASS"); \
    usermod -aG sudo $USER; \
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

CMD rm -f /var/run/xrdp/xrdp*.pid >/dev/null 2>&1; \
    service dbus restart >/dev/null 2>&1; \
    /usr/lib/systemd/systemd-logind >/dev/null 2>&1 & \
    [ -f /usr/sbin/sshd ] && /usr/sbin/sshd; \
    xrdp-sesman --config /etc/xrdp/sesman.ini; \
    xrdp --nodaemon --config /etc/xrdp/xrdp.ini

# docker build -t ubuntu-rdp -f ubuntu-rdp.dockerfile .
# docker run -it -p 3389:3389 -p 22:22 ubuntu-rdp