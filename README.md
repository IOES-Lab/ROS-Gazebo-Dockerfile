# Dockerfile for ROS Rolling and Gazebo Garden

## 자동 스크립트 사용 빌드 & 실행

- 자동으로 NVIDIA GPU 카드가 있는지 없는지 인식해서 빌드 및 실행
- Host머신의 홈디렉토리를 컨테이너의 도커 내부 host폴더에 마운트

- 도커를 sudo 없이 실행되도록 설정해두어야 함
  
  ```bash
  sudo groupadd docker
  sudo usermod -aG docker $USER
  newgrp docker
  ```

- (NVIDIA GPU카드가 있는경우!) 아래 사용전 Nvidia-Docker설치 및 설정 필요
  - nvidia-docker2 설치
    - 도커 컨테이너에 호스트 리눅스 머신의 nvidia 그래픽 카드를 사용하기 위해 nvidia-docker2를 설치
  
    ```
    sudo apt-get install nvidia-docker2
    ```
  ※설치가 안된다면?
  아래 명령어 실행
    
    ```
    sudo apt-get update
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
                 && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
                 && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    sudo apt-get update
    sudo apt-get install nvidia-docker2
    ```
- 이미지 빌드
  
  ```bash
  ./build.bash
  ```

- 이미지 실행
  
  ```bash
  xhost +
  ./run.bash
  ```

- 실행중인 이미지에 접속
  
  ```bash
  ./join.bash
  ```

---

## 매뉴얼 빌드 & 실행

### 도커 이미지 빌드
- VMWare 또는 Nvidia 그래픽 카드가 없는 리눅스머신
  
  ```bash
  docker build -f rolling-harmonic.dockerfile -t ros-gazebo:latest .
  ```

- Nvidia 그래픽 카드가 있는 리눅스머신
  - ros-gazebo이미지 이름에 nvidia태그를 달아 빌드
  
  ```bash
  docker build -f rolling-harmonic-nvidia.dockerfile -t ros-gazebo:nvidia .
  ```

### 도커 이미지 실행
- VMWare 또는 Nvidia 그래픽 카드가 없는 리눅스머신
  
  ```bash
  xhost +
  docker run -it --rm --privileged -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY -v ~/:/home/ioes-docker/host ros-gazebo:latest
  ```

- Nvidia 그래픽 카드가 있는 리눅스머신
  - nvidia-docker2 설치
    - 도커 컨테이너에 호스트 리눅스 머신의 nvidia 그래픽 카드를 사용하기 위해 nvidia-docker2를 설치
  
    ```
    sudo apt-get install nvidia-docker2
    ```
  - docker run
    - 도커 ㅅ컨테이너 실행시 nvidia 런타임을 사용하도록 설정, 호스트 리눅스 머신의 /dev/dri를 컨테이너의 /dev/dri에 마운트
  
    ```bash
    xhost +
    docker run --runtime=nvidia --rm --gpus all -v /dev/dri:/dev/dri -it --privileged -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY -v ~/:/home/ioes-docker/host -v "/etc/localtime:/etc/localtime:ro" -e QT_X11_NO_MITSHM=1 --security-opt seccomp=unconfined ros-gazebo:latest
    ```

---

## Obsolete
- 맥 (작동안됨)
  
  ```bash
  xhost +${HOSTNAME}
  docker run -it --rm --privileged --env="DISPLAY=host.docker.internal:0" -v /dev:/dev --group-add dialout -v /tmp/.X11-unix:/tmp/.X11-unix:ro ros-gazebo
  ```
