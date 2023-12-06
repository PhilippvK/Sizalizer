#!/bin/bash


SCRIPT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "$SCRIPT_ROOT/riscv-gnu-toolchain"
# sudo apt-get install autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev

./configure --prefix=/opt/riscv32 --with-arch=rv32gc --with-abi=ilp32d --enable-gdb

make
make clean

make linux
make clean

make build-qemu
make clean

make build-binutils
make clean

make build-gdb
make clean

make build-libc
make clean

make build-llvm
make clean

cd "$SCRIPT_ROOT"
