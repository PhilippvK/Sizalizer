#!/bin/bash

set -ue

# SCRIPT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# BUILD_DIR="${SCRIPT_ROOT}/llvm-project/build"
BUILD_DIR=/llvm-project/build

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# clang++: error: -gsplit-dwarf is unsupported with RISC-V linker relaxation (-mrelax)
cmake -G Ninja \
	-DLLVM_PARALLEL_LINK_JOBS=2 		\
	-DLLVM_PARALLEL_COMPILE_JOBS=4 		\
	-DLLVM_RAM_PER_COMPILE_JOB=5000 	\
	-DLLVM_RAM_PER_LINK_JOB=15000		\
	-DCMAKE_BUILD_TYPE=MinRelSize   \
	-DCMAKE_C_Compiler="/opt/riscv/bin/clang" \
	-DCMAKE_CXX_Compiler="/opt/riscv/bin/clang++" \
	-DDEFAULT_SYSROOT="/opt/riscv/riscv32-unknown-elf" \
	-DGCC_INSTALL_PREFIX="/opt/riscv" 	\
	-DLLVM_ENABLE_PROJECTS="clang;libc;ldd;mlir"      \
	-DLLVM_TARGET_ARCH="riscv32gc"  	\
	-DLLVM_TARGETS_TO_BUILD="RISCV" 	\
	-DLLVM_DEFAULT_TARGET_TRIPLE="riscv32-unknown-elf" \
	-DLLVM_ENABLE_WARNINGS=ON			\
	-DLLVM_ENABLE_WERROR=OFF			\
	-DLLVM_USE_SPLIT_DWARF=OFF			\
	-DLLVM_OPTIMIZED_TABLEGEN=ON		\
	"/llvm-project/llvm"

cmake --build .
cmake --build . --target install

#make check-all

cd "/"
