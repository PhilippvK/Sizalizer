#!/bin/bash

set -ue

# SCRIPT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# BUILD_DIR="${SCRIPT_ROOT}/llvm-project/build"
BUILD_DIR=/llvm-project/build

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# clang++: error: -gsplit-dwarf is unsupported with RISC-V linker relaxation (-mrelax)
cmake -G Ninja \
	-DLLVM_PARALLEL_LINK_JOBS=2 \
	-DLLVM_PARALLEL_COMPILE_JOBS=4 \
	-DLLVM_RAM_PER_COMPILE_JOB=7500 \
	-DLLVM_RAM_PER_LINK_JOB=15000	\
	-DCMAKE_BUILD_TYPE=RelWithDebInfo        \
	-DCMAKE_C_Compiler="/opt/riscv/bin/clang" \
	-DCMAKE_CXX_Compiler="/opt/riscv/bin/clang++" \
	-DDEFAULT_SYSROOT="/opt/riscv/riscv32-unknown-elf" \
	-DGCC_INSTALL_PREFIX="/opt/riscv" \
	-DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;libc;libclc;lld;mlir"      \
	-DLLVM_TARGET_ARCH="RISCV" \
	-DLLVM_TARGETS_TO_BUILD="RISCV" \
	-DLLVM_DEFAULT_TARGET_TRIPLE="riscv32-unknown-elf" \
	-DLLVM_ENABLE_RUNTIMES=all \
	-DLLVM_BUILD_DOCS=OFF           \
	-DLLVM_BUILD_TOOLS=ON           \
	-DLLVM_BUILD_TESTS=ON          \
	-DLLVM_ENABLE_LTO=OFF           \
	-DLLVM_ENABLE_DOXYGEN=OFF       \
	-DLLVM_ENABLE_RTTI=ON          	\
	-DLLVM_ENABLE_UNWIND_TABLES=OFF \
	-DLLVM_ENABLE_WARNINGS=ON		\
	-DLLVM_ENABLE_WERROR=OFF		\
	-DLLVM_USE_SPLIT_DWARF=OFF		\
	-DLLVM_OPTIMIZED_TABLEGEN=ON	\
	-DLLVM_STATIC_LINK_CXX_STDLIB=OFF	\
    -DLLVM_ENABLE_LIBCXX=OFF 		\
	-DLLVM_ENABLE_LLVM_LIBC=OFF		\
	"/llvm-project/llvm"
cmake --build .
cmake --build . --target install

make check-all

cd "/"
