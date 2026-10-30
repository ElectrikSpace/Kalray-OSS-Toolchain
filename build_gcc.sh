#!/bin/bash
# Build the open source Kalray GCC (stage 1, C only, freestanding) for kvx (kv3-2).
# Out-of-tree build in ./build/gcc, installed to ./install.
# Requires binutils to be installed first (see build_binutils.sh).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="${ROOT}/gcc"
BUILD="${BUILD:-${ROOT}/build/gcc}"
PREFIX="${PREFIX:-${ROOT}/install}"
ARCH="${ARCH:-kv3-2}"
TARGET="${TARGET:-kvx-cos}"
LANGUAGES="${LANGUAGES:-c}"
JOBS="${JOBS:-$(nproc)}"

if [ ! -x "${PREFIX}/bin/${TARGET}-as" ]; then
    echo "error: ${PREFIX}/bin/${TARGET}-as not found; run TARGET=${TARGET} ./build_binutils.sh first" >&2
    exit 1
fi

# Make the freshly installed binutils visible to configure and the build.
export PATH="${PREFIX}/bin:${PATH}"

mkdir -p "${BUILD}"
cd "${BUILD}"

"${SRC}/configure" \
    --target="${TARGET}" \
    --prefix="${PREFIX}" \
    --with-arch="${ARCH}" \
    --enable-languages="${LANGUAGES}" \
    --without-headers \
    --disable-nls \
    --disable-werror \
    --disable-shared \
    --disable-threads \
    --disable-libssp \
    --disable-libgomp \
    --disable-libatomic \
    --disable-libquadmath \
    --disable-libsanitizer \
    --disable-libstdcxx \
    --disable-bootstrap \
    --disable-multilib

make -j"${JOBS}" all-gcc
make -j"${JOBS}" all-target-libgcc CFLAGS_FOR_TARGET="-g -O2 -Dinhibit_libc -U__CLUSTER_OS__"
make install-gcc install-target-libgcc

echo "Installed gcc for ${TARGET} (${ARCH}) in ${PREFIX}"
echo "Use: ${PREFIX}/bin/${TARGET}-gcc -march=${ARCH} ..."
