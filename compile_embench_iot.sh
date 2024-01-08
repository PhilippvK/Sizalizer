#!/bin/bash

set -ue

SCRIPT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EMBENCH_DIR="${SCRIPT_ROOT}/embench-iot"
BUILD_DIR="${EMBENCH_DIR}/build"
LOG_DIR="${EMBENCH_DIR}/log"

cd "$EMBENCH_DIR"

python3 ./build_all.py \
    --builddir "$BUILD_DIR" \
    --logdir "$LOG_DIR" \
    --arch riscv32 \
    --board ri5cyverilator \
    --cc /opt/riscv/bin/clang \
    --ld /opt/riscv/bin/ld.lld \
    --cflags "--target=riscv32 -march=rv32i -static" \
    --cpu-mhz 1 \
    --warmup-heat 1 \
    --timeout 10

cd "$SCRIPT_ROOT"
