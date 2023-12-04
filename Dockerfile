FROM ubuntu:22.04
LABEL version="1.0"
LABEL description="Image for DAG analysis"
# apt prompts
RUN apt-get update
# install deps
RUN apt-get install -y libcap-dev build-essential cmake clang pkg-config libmount-dev python3.8 python3-pip git zip wget dbus ninja-build meson m4 gperf libseccomp-dev gcc nano strace cproto


#####################################
#### Copy folders of the context ####
#####################################
WORKDIR /
    # Compile clang, clang++, rvstore, ...
    COPY llvm-project /llvm-project

####################
#### Clone llvm ####
####################
# WORKDIR /
#     RUN wget https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2023.11.22/riscv32-glibc-ubuntu-22.04-llvm-nightly-2023.11.22-nightly.tar.gz
#     RUN tar xf riscv32-glibc-ubuntu-22.04-llvm-nightly-2023.11.22-nightly.tar.gz

####################################################
#### Build Clang, Passes, rvstore and set paths ####
####################################################
WORKDIR /llvm-project
    RUN ./compile_llvm.sh

WORKDIR /llvm-project
    # Set Path to compilde clang, clang++, rvstore, ...
    ARG BUILD_PATH="/llvm-project/build"
    ARG BUILD_BIN="$BUILD_PATH/bin"
    ARG BUILD_LIB="$BUILD_PATH/lib"

    ARG CLANGPP="$BUILD_BIN/clang++"
    ARG CLANG="$BUILD_BIN/clang"

    ARG LOAD_FLAGS="-Xclang -load -Xclang"

WORKDIR /
    RUN export ASAN_SYMBOLIZER=$BUILD_BIN/llvm-symbolizer
    RUN export ASAN_OPTIONS=detect_leaks=0

