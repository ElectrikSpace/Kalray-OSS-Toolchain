#!/bin/bash
# Build the whole open source Kalray toolchain (binutils, gcc, newlib, qemu; no llvm)
# into a single prefix, then run the hello world test on qemu.
#
# Usage: [ARCH=kv3-1] [TARGET=kvx-elf] [PREFIX=dir] [JOBS=n] ./build_all.sh
# ARCH may be kv3-1 or kv3-2 for binutils/gcc/newlib. QEMU only emulates kv3-1,
# so the hello world is only run on QEMU when ARCH=kv3-1 (otherwise just compiled).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ARCH="${ARCH:-kv3-1}"
export TARGET="${TARGET:-kvx-elf}"
export PREFIX="${PREFIX:-${ROOT}/install-${ARCH}}"

# Per-arch build dirs so several archs can coexist; binutils is arch independent.
BUILD_BASE="${ROOT}/build"
BUILD="${BUILD_BASE}/binutils-${ARCH}" "${ROOT}/build_binutils.sh"
BUILD="${BUILD_BASE}/gcc-${ARCH}" "${ROOT}/build_gcc.sh"
BUILD="${BUILD_BASE}/newlib-${ARCH}" "${ROOT}/build_newlib.sh"
"${ROOT}/build_qemu.sh"

if [ "${ARCH}" != "kv3-1" ]; then
    make -C "${ROOT}/tests" TOOLCHAIN="${PREFIX}" ARCH="${ARCH}" TARGET="${TARGET}"
    echo "Toolchain built in ${PREFIX}; hello world compiled but not run (QEMU only supports kv3-1)"
    exit 0
fi

out="$(make -C "${ROOT}/tests" run TOOLCHAIN="${PREFIX}" ARCH="${ARCH}" TARGET="${TARGET}" 2>&1)"
echo "${out}"
if ! grep -q "Hello, kvx!" <<< "${out}"; then
    echo "error: hello world test failed" >&2
    exit 1
fi
echo "Toolchain built in ${PREFIX} and hello world test passed"
