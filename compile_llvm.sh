#!/bin/bash

set -ue

SCRIPT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="${SCRIPT_ROOT}/llvm-project/build"


mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

cmake -G Ninja \
	-DLLVM_PARALLEL_LINK_JOBS=2 \
	-DLLVM_PARALLEL_COMPILE_JOBS=6 \
	-DLLVM_RAM_PER_COMPILE_JOB=3333 \
	-DLLVM_RAM_PER_LINK_JOB=10000	\
	-DCMAKE_BUILD_TYPE=Debug        \
	-DCMAKE_C_Compiler=/usr/bin/clang \
	-DCMAKE_C_Compiler=/usr/bin/clang++ \
	-DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;libc;libclc;lld;lldb;mlir"      \
	-DLLVM_ENABLE_RUNTIMES=all \
	-DLLVM_TARGETS_TO_BUILD="RISCV" \
	-DLLVM_TARGET_ARCH="RISCV"		\
	-DLLVM_USE_LINKER=/usr/bin/lld 	\
	-DBUILD_SHARED_LIBS=OFF         \
	-DLLVM_BUILD_32_BITS=ON			\
	-DLLVM_BUILD_DOCS=OFF           \
	-DLLVM_BUILD_TOOLS=ON           \
	-DLLVM_BUILD_TESTS=OFF          \
	-DLLVM_ENABLE_LTO=OFF           \
	-DLLVM_ENABLE_DOXYGEN=OFF       \
	-DLLVM_ENABLE_RTTI=ON          	\
	-DLLVM_ENABLE_UNWIND_TABLES=OFF \
	-DLLVM_ENABLE_WARNINGS=ON		\
	-DLLVM_ENABLE_WERROR=OFF		\
	-DLLVM_USE_SPLIT_DWARF=ON		\
	-DLLVM_STATIC_LINK_CXX_STDLIB=OFF	\
    -DLLVM_DEFAULT_TARGET_TRIPLE="riscv32imac-unknown-none-elf" \
	-DLLVM_ENABLE_LIBCXX=OFF 		\
	-DLLVM_ENABLE_LLVM_LIBC=OFF		\
	"$SCRIPT_ROOT/llvm-project/llvm"
cmake --build .
cmake --build . --target install

cd "$SCRIPT_ROOT"
