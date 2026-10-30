#!/bin/bash
# Build newlib (+ libgloss) for kvx (kv3-2) with the toolchain installed in ./install.
# Out-of-tree build in ./build/newlib, installed to ./install.
# Requires build_binutils.sh and build_gcc.sh to have been run first.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="${ROOT}/newlib"
BUILD="${BUILD:-${ROOT}/build/newlib}"
PREFIX="${PREFIX:-${ROOT}/install}"
ARCH="${ARCH:-kv3-2}"
TARGET="${TARGET:-kvx-cos}"
JOBS="${JOBS:-$(nproc)}"

if [ ! -x "${PREFIX}/bin/${TARGET}-gcc" ]; then
    echo "error: ${PREFIX}/bin/${TARGET}-gcc not found; run build_binutils.sh and build_gcc.sh first" >&2
    exit 1
fi

export PATH="${PREFIX}/bin:${PATH}"

mkdir -p "${BUILD}"
cd "${BUILD}"

"${SRC}/configure" \
    --target="${TARGET}" \
    --prefix="${PREFIX}" \
    --disable-nls \
    --disable-werror \
    --disable-multilib \
    --enable-newlib-io-long-long \
    --enable-newlib-io-c99-formats \
    CFLAGS_FOR_TARGET="-O2 -march=${ARCH}"

make -j"${JOBS}"
make install

echo "Installed newlib for ${TARGET} (${ARCH}) in ${PREFIX}"
