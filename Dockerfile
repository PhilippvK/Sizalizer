FROM ubuntu:22.04
LABEL version="1.0"
LABEL description="Image for DAG analysis"
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

RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean


#####################################
#### Copy folders of the context ####
#####################################
WORKDIR /
    # Compile clang, clang++, ...
    #COPY llvm-project /llvm-project

#########################################
#### Clone & Build RISCV32 Toolchain ####
#########################################
#     RUN wget https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2023.11.22/riscv32-glibc-ubuntu-22.04-llvm-nightly-2023.11.22-nightly.tar.gz
WORKDIR /
    RUN git clone https://github.com/riscv-collab/riscv-gnu-toolchain

WORKDIR /riscv-gnu-toolchain
    RUN ./configure --prefix=/opt/riscv --with-arch=rv32gc --with-abi=ilp32d --enable-gdb
    RUN make -j 6
    RUN make clean
    RUN make -j 6 linux
    RUN make clean
    # Build qemu
    RUN make -j 6 build-qemu
    RUN make clean
    RUN make -j 6 build-binutils
    RUN make clean
    RUN make -j 6 build-gdb
    RUN make clean
    RUN make -j 6 build-gcc1 
    RUN make clean
    RUN make -j 6 build-libc
    RUN make clean
    RUN make -j 6 build-gcc2
    RUN make clean
    RUN make -j 6 build-llvm
    RUN make clean

####################
#### Clone llvm ####
####################
# WORKDIR /
#     RUN wget https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2023.11.22/riscv32-glibc-ubuntu-22.04-llvm-nightly-2023.11.22-nightly.tar.gz
#     RUN tar xf riscv32-glibc-ubuntu-22.04-llvm-nightly-2023.11.22-nightly.tar.gz

###########################################
#### Build Clang, Passes and set paths ####
###########################################
# WORKDIR /llvm-project
#     RUN ./compile_llvm.sh

# WORKDIR /llvm-project
    # Set Path to compilde clang, clang++, rvstore, ...
#     ARG BUILD_PATH="/llvm-project/build"
#     ARG BUILD_BIN="$BUILD_PATH/bin"
#     ARG BUILD_LIB="$BUILD_PATH/lib"

#     ARG CLANGPP="$BUILD_BIN/clang++"
#     ARG CLANG="$BUILD_BIN/clang"

#     ARG LOAD_FLAGS="-Xclang -load -Xclang"

WORKDIR /
#    RUN export ASAN_SYMBOLIZER=$BUILD_BIN/llvm-symbolizer
#     RUN export ASAN_OPTIONS=detect_leaks=0

