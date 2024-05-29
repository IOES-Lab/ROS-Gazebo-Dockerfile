# Dockerfile for ROS Rolling and Gazebo Garden

## Automated Build & Run Script

- Automatically detects if an NVIDIA GPU card is present and builds/runs accordingly.
- Mounts the host machine's home directory inside the container under a folder named 'host'.

- Docker should be set up to run without sudo:

  ```bash
  sudo groupadd docker
  sudo usermod -aG docker $USER
  newgrp docker
  ```

- (If an NVIDIA GPU card is present!) Installation and setup of Nvidia-Docker required before use:
  - Install nvidia-docker2
    - To allow the Docker container to use the host Linux machine's NVIDIA graphics card, install nvidia-docker2:
  
    ```
    sudo apt-get install nvidia-docker2
    ```
  ※ If the installation fails?
  Run the following command:
    
    ```
    sudo apt-get update
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
                 && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
                 && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    sudo apt-get update
    sudo apt-get install nvidia-docker2
    ```
- Build the image
  
  ```bash
  ./build.bash
  ```

- Run the image
  
  ```bash
  xhost +
  ./run.bash
  ```

- Connect to a running image
  
  ```bash
  ./join.bash
  ```

---

## Manual Build & Run

### Docker Image Build
- For Linux machines without VMWare or an Nvidia graphics card:
  
  ```bash
  docker build -f rolling-harmonic.dockerfile -t ros-gazebo:latest .
  ```

- For Linux machines with an Nvidia graphics card:
  - Build with an 'nvidia' tag for the ros-gazebo image:
  
  ```bash
  docker build -f rolling-harmonic-nvidia.dockerfile -t ros-gazebo:nvidia .
  ```

### Docker Image Run
- For Linux machines without VMWare or an Nvidia graphics card:
  
  ```bash
  xhost +
  docker run -it --rm --privileged -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY -v ~/:/home/ioes-docker/host ros-gazebo:latest
  ```

- For Linux machines with an Nvidia graphics card:
  - Install nvidia-docker2
    - To allow the Docker container to use the host Linux machine's NVIDIA graphics card, install nvidia-docker2:
  
    ```
    sudo apt-get install nvidia-docker2
    ```
  - Run docker with Nvidia runtime:
    - Set up to use the Nvidia runtime during Docker container execution, and mount the host Linux machine's /dev/dri to the container's /dev/dri:
  
    ```bash
    xhost +
    docker run --runtime=nvidia --rm --gpus all -v /dev/dri:/dev/dri -it --privileged -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY -v ~/:/home/ioes-docker/host -v "/etc/localtime:/etc/localtime:ro" -e QT_X11_NO_MITSHM=1 --security-opt seccomp=unconfined ros-gazebo:nvidia
    ```

---