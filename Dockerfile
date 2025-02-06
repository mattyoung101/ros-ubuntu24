FROM ubuntu:24.10

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Brisbane
# Use Australian Ubuntu archive, https://gist.github.com/magnetikonline/3a841b5268d5581b4422
# If you're not down under, you will probably want to change this to your local mirror
RUN sed --in-place --regexp-extended "s/(\/\/)(archive\.ubuntu)/\1au.\2/" /etc/apt/sources.list.d/ubuntu.sources
# Install all the dependencies of all the build tools
RUN apt update && apt install -y \
    build-essential \
    python3 \
    wget \
    curl \
    lsb-release \
    software-properties-common \
    gnupg \
    python3-pip \
    cmake \
    python3-nose \
    libgtest-dev \
    libboost-all-dev \
    python3-empy \
    libconsole-bridge-dev \
    libtinyxml-dev \
    liblz4-dev \
    libbz2-dev \
    libpoco-dev \
    libtinyxml2-dev \
    pkg-config \
    liblog4cxx-dev

# Install pip packages
WORKDIR /build
RUN pip install --break-system-packages rosdep rosinstall_generator vcstool

# Build ROS
RUN rosdep init && rosdep update
RUN rosinstall_generator desktop --rosdistro noetic --deps --tar > noetic-desktop.rosinstall
RUN mkdir ./src && vcs import --input noetic-desktop.rosinstall ./src

# FIXME: apply patch set from https://github.com/RoboStack/ros-noetic/tree/main/patch

RUN ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release
