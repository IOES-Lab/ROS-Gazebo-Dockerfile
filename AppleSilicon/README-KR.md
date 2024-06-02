# Dockerfiles for M1 Macbook

## 추천 : ARM64 Ubuntu Docker와 원격 데스크탑 연결
- remote-desktop : run and access using remote desktop client
  ```bash
  docker build -f remote-desktop/jazzy-harmonic-rdp.dockerfile -t jazzy-harmonic-rdp .
  docker run -it -p 3389:3389 jazzy-harmonic-rdp
  ```

## 추천 : ARM64 Ubuntu Lima 구동
Mac OS X는 리눅스 환경과 유사하나 애플의 전용 애플 실리콘 (M1 칩 이후) 적용 이후 기존의 인텔 기반 컴퓨터들(X86_64 아키텍쳐)과 다른 CPU 아키텍쳐가 되었다. 이는 라즈베리 파이나 안드로이드와 유사한 ARM64 아키텍쳐을 이용하여 전력비를 극대화하는 방법에 해당한다.

Lima는 현재도 활발히 개발되고 있는 패키지로 윈도우의 WSL과 매우 유사한 개발환경을 제공한다. 아직 Wayland를 이용한 직접적 GUI구동은 제공되지 않으나, 이부분은 원격데크트톱 접속으로 해결할 수 있다.

- Lima를 이용해 Ubuntu 22.04　설치
  
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

원격 데스크탑 어플로 localhost　아이피주소에 접속. 이때 사용자명은 Mac OS 터미널의 사용자명과 같고 (Lima 내에서 whoami　명령어를 통해서도 확인 가능하다) 비밀번호는 앞서 설정한 값과 같다. 접속 시 Administrator의 비밀번호를 묻는데 취소로 무시해주면 된다.

관련해 추가 연구가 필요한 내용

- Wayland ported Owl : https://github.com/lima-vm/lima/issues/2
- WSLg와 같이 Wayland를 직접 이용하는 방법으로 lima의 Issue 번호 2번으로 초기부터 논의되어왔으나 아직 만들어지지 않음


### Commands
- remote-desktop : run and access using remote desktop client
  ```bash
  docker build -f remote-desktop/jazzy-harmonic-rdp.dockerfile -t jazzy-harmonic-rdp .
  docker run -it --rm --privileged -p 3389:3389 jazzy-harmonic-rdp
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
