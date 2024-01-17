#!/bin/bash

set -ue

SCRIPT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EMBENCH_DIR="${SCRIPT_ROOT}/embench-iot"
BUILD_DIR="${EMBENCH_DIR}/build"
LOG_DIR="${EMBENCH_DIR}/log"

cd "$EMBENCH_DIR"

# Build benchmarks
python3 ./build_all.py \
                    --clean \
                    --verbose \
                    --arch=riscv32 \
                    --chip=generic \
                    --board=ri5cyverilator \
                    --cc=clang \
                    --cflags="-fno-builtin-bcmp -Oz -msave-restore -fpass-plugin=/home/ahc/Desktop/CodeComp/seal/llvm-pass-plugin/build/libLLVMCDFG.so" \
                    --ldflags="-nostartfiles -nostdlib" \
                    --dummy-libs="crt0 libc libgcc libm"

# Run benchmarks
python3 ./benchmark_size.py --json-output --json-comma


cd "$SCRIPT_ROOT"
