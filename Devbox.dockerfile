# Dockerfile for local development, allows for mounting a build directory and
# re-using build artifacts.
# Use the devbox interactively:
#   docker build -f Devbox.dockerfile -t devbox .
#   docker run -it devbox -v /tmp/build:/llvm-project/build
FROM ubuntu:22.04
LABEL version="1.0"
LABEL description="SEAL Image"
# apt prompts
RUN apt-get update
RUN apt-get upgrade -y
# install deps
RUN apt-get install -y fish \
                    binutils \
                    grep \
                    sed \
                    build-essential \
                    make \
                    cmake \
                    clang \
                    llvm \
                    pkg-config \
                    python3 \
                    python3-pip \
                    python-is-python3 \
                    git \
                    zip \
                    gzip \
                    unzip \
                    wget \
                    dbus \
                    ninja-build \
                    meson \
                    m4 \
                    gperf \
                    gcc \
                    g++ \
                    nano \
                    strace \
                    cproto \
                    autoconf \
                    automake \
                    curl \
                    gawk \
                    build-essential \
                    bison \
                    flex \
                    texinfo \
                    gperf \
                    libtool \
                    patchutils \
                    bc \
                    libmount-dev \
                    libfdt-dev \
                    libseccomp-dev \
                    autotools-dev \
                    libexpat1-dev \
                    libpixman-1-dev \
                    libmpc-dev \
                    libmpfr-dev \
                    libgmp-dev \
                    libcap-dev \
                    zlib1g-dev \
                    libexpat-dev \
                    libglib2.0-dev


RUN pip3 install pyelftools

##################################
#### Download riscv Toolchain ####
##################################
WORKDIR /opt
    RUN wget -q https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2023.11.22/riscv32-glibc-ubuntu-22.04-llvm-nightly-2023.11.22-nightly.tar.gz \
        && tar xf riscv32-glibc-ubuntu-22.04-llvm-nightly-2023.11.22-nightly.tar.gz \
        && rm riscv32-glibc-ubuntu-22.04-llvm-nightly-2023.11.22-nightly.tar.gz

#####################################
#### Copy folders of the context ####
#####################################
WORKDIR /
    COPY compile_llvm.sh /
    COPY llvm-project /llvm-project

    COPY compile_embench_iot.sh /
    COPY embench-iot /embench-iot

###########################################
#### Build Clang, Passes and set paths ####
###########################################
WORKDIR /
    RUN mkdir /llvm-project/build

# WORKDIR /llvm-project
    # Set Path to compilde clang, clang++, ...
#     ARG BUILD_PATH="/llvm-project/build"
#     ARG BUILD_BIN="$BUILD_PATH/bin"
#     ARG BUILD_LIB="$BUILD_PATH/lib"

#     ARG CLANGPP="$BUILD_BIN/clang++"
#     ARG CLANG="$BUILD_BIN/clang"

#     ARG LOAD_FLAGS="-Xclang -load -Xclang"

WORKDIR /
#    RUN export ASAN_SYMBOLIZER=$BUILD_BIN/llvm-symbolizer
#     RUN export ASAN_OPTIONS=detect_leaks=0

VOLUME /llvm-project/build

ENTRYPOINT /bin/sh