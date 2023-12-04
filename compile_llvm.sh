#!/bin/bash

set -ue

SCRIPT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="${SCRIPT_ROOT}/llvm-project/build"


mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

cmake -G Ninja \
	-DCMAKE_BUILD_TYPE=Debug        \
	-DBUILD_SHARED_LIBS=True          \
	-DLLVM_BUILD_TOOLS=True           \
	-DLLVM_BUILD_TESTS=False          \
	-DLLVM_BUILD_DOCS=False           \
	-DLLVM_ENABLE_LTO=False           \
	-DLLVM_ENABLE_DOXYGEN=False       \
	-DLLVM_ENABLE_RTTI=False          \
	-DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;libc;libclc;lld;lldb;mlir"      \
	-DLLVM_TARGETS_TO_BUILD="RISCV" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-linux-gnu" \
	"$SCRIPT_ROOT/llvm-project/llvm"
ninja

cd "$SCRIPT_ROOT"
