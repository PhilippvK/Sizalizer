#!/bin/bash

set -ue

SCRIPT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="${SCRIPT_ROOT}/llvm-project/build"


mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

cmake -G Ninja \
	-DCMAKE_BUILD_TYPE=Debug        \
	-DBUILD_SHARED_LIBS=On          \
	-DLLVM_BUILD_TOOLS=On           \
	-DLLVM_BUILD_TESTS=Off          \
	-DLLVM_BUILD_DOCS=Off           \
	-DLLVM_ENABLE_LTO=Off           \
	-DLLVM_ENABLE_DOXYGEN=Off       \
	-DLLVM_ENABLE_RTTI=Off          \
	-DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;compiler-rt;libc;libclc;lld;lldb;mlir"      \
  	-DDEFAULT_SYSROOT="/opt/riscv/riscv32-unknown-elf" \
	-DCMAKE_INSTALL_PREFIX="../_install" \
	-DGCC_INSTALL_PREFIX="/opt/riscv" \
	-DLLVM_TARGETS_TO_BUILD="RISCV" \
  	-DLLVM_DEFAULT_TARGET_TRIPLE="riscv32-unknown-elf" \
    -DCMAKE_CXX_COMPILER=clang++    \
    -DCMAKE_C_COMPILER=clang        \
	"$SCRIPT_ROOT/llvm-project/llvm"
ninja

cd "$SCRIPT_ROOT"
