#!/bin/bash
# Build the open source Kalray binutils for kvx (kv3-2 core).
# Out-of-tree build in ./build/binutils, installed to ./install.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="${ROOT}/binutils"
BUILD="${BUILD:-${ROOT}/build/binutils}"
PREFIX="${PREFIX:-${ROOT}/install}"
TARGET="${TARGET:-kvx-cos}"
JOBS="${JOBS:-$(nproc)}"

# The kv3-2 core is selected at assembly time with -march=kv3-2.
mkdir -p "${BUILD}" "${PREFIX}"
cd "${BUILD}"

"${SRC}/configure" \
    --target="${TARGET}" \
    --prefix="${PREFIX}" \
    --disable-nls \
    --disable-werror \
    --disable-gdb \
    --disable-sim \
    --disable-gprofng \
    --disable-gold \
    --disable-libctf \
    --disable-multilib \
    --with-system-zlib \
    --enable-deterministic-archives

make -j"${JOBS}"
make install

echo "Installed binutils for ${TARGET} (kv3-2) in ${PREFIX}"
echo "Use: ${PREFIX}/bin/${TARGET}-as -march=kv3-2 ..."
