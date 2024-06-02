# Dockerfiles for M1 Macbook

## Recommended : Running ARM64 Ubuntu with Lima
Mac OS X is similar to a Linux environment, but after Apple's introduction of their proprietary Apple Silicon (M1 chip and later), it has a different CPU architecture compared to previous Intel-based computers (X86_64 architecture). This is similar to the ARM64 architecture used in Raspberry Pi and Android, which maximizes power efficiency.
Lima is a package that is still actively being developed and provides a development environment very similar to Windows' WSL. Although it does not yet provide direct GUI operation using Wayland, this can be resolved through remote desktop access.

- Installing Ubuntu 22.04 using Lima

    ```bash
    # Install brew package manger
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Install Lima with brew 
    brew install lima
    # Set Virtual Machine ubuntu 22.04 (ARM64 Arch)
    limactl start --name=ubuntu-22.04 https://raw.githubusercontent.com/lima-vm/lima/master/examples/ubuntu-lts.yaml
    # Set X86_64 Virtual Machine with Rosetta2
    limactl start --name=ubuntu-x86_64 https://raw.githubusercontent.com/lima-vm/lima/master/examples/experimental/vz.yaml
    ```

- Run Lima and set password

    ```bash
    # Find out default username
    whoami 
    limactl shell ubuntu-22.04
    sudo passwd $(whoami)
    # Add user to sudo and GUI group
    sudo usermod -a -G sudo $(whoami)  
    sudo usermod -a -G adm $(whoami)
    ```

- Install GUI Desktop and XRDP

    ```bash
    sudo apt update && sudo apt -y upgrade
    # Keep current ssh config when asked
    sudo apt install -y ubuntu-desktop xrdp
    sudo systemctl start xrdp  
    # Now collect with RDP client to localhost
    ```

Connect to the localhost IP address using a remote desktop application. At this time, the username is the same as the Mac OS terminal username (also can be checked with the whoami command inside Lima), and the password is the same as the value set earlier. When connecting, it will ask for the Administrator's password, but this can be ignored by clicking Cancel.
Additional research is needed on the following:

- Wayland ported Owl: https://github.com/lima-vm/lima/issues/2
- A method of directly using Wayland like WSLg has been discussed from the beginning as Lima's Issue number 2, but it has not been created yet.


### Commands
- remote-desktop : run and access using remote desktop client
  ```bash
  docker build -f remote-desktop/jazzy-harmonic-rdp.dockerfile -t jazzy-harmonic-rdp .
  docker run -it -p 3389:3389 -p 22:22 jazzy-harmonic-rdp
  ```
- novnc : view gui on browser (no direct copy and paste)
  ```
  docker build -f novnc/jazzy-harmonic-novnc.Dockerfile -t jazzy-harmonic-novnc .
  docker run -it -p 6080:6080 v
  # http://localhost:6080/vnc.html
  ```
  
- generic : run in terminal


### Other notes
M1 Macbook running X86 Docker container : [Notion 
Page](https://yeongdocat.notion.site/M1-Macbook-running-X86-Docker-container-e2cfaaadfffd4acdb4101d90e2750805)
