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
    liblog4cxx-dev \
    git \
    fd-find \
    python-is-python3 \
    qtbase5-dev \
    qt5-qmake \
    libgraphviz-dev \
    python3-dev \
    python3-sip

# Install pip packages
RUN pip install --break-system-packages \
    rosdep \
    rosinstall_generator \
    vcstool \
    bloom \
    sip \
    pyqt5 \
    pygraphviz \
    pydot \
    catkin-tools-python \
    colcon-common-extensions

# Install patches
WORKDIR /patches
RUN git clone https://github.com/RoboStack/ros-noetic.git
RUN cd ros-noetic && git checkout 330ac1d36e6410683c039fbad4b60b60a61c8b6b

# Build ROS
WORKDIR /build
RUN rosdep init && rosdep update
RUN rosinstall_generator desktop --rosdistro noetic --deps --tar > noetic-desktop.rosinstall
RUN mkdir ./src && vcs import --input noetic-desktop.rosinstall ./src

# Apply patches
RUN cd src/rosconsole && git apply /patches/ros-noetic/patch/ros-noetic-rosconsole.patch
RUN cd src/rqt/rqt_gui_cpp && git apply /patches/ros-noetic/patch/ros-noetic-rqt-gui-cpp.patch

# RUN find . | grep rqt && sleep 999

# Build
# RUN ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release
RUN colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release --packages-ignore \
    qt_gui_cpp \
    rqt_gui_cpp \
    urdf_parser_plugin
