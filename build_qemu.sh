#!/bin/bash
# Build the Kalray QEMU (kvx-softmmu) directly from ./qemu (coolidge-6.1 branch).
# QEMU's kvx target needs SoftFloat and LAO, so these are built first.
# Build trees in ./build/{softfloat,lao,qemu}, installed to ./install.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QEMU_SRC="${ROOT}/qemu"
LAO_SRC="${ROOT}/lao"
PREFIX="${PREFIX:-${ROOT}/install}"
BUILD="${ROOT}/build"
QEMU_BRANCH="${QEMU_BRANCH:-coolidge-6.1}"
LAO_BRANCH="${LAO_BRANCH:-coolidge}"
SOFTFLOAT_URL="http://www.jhauser.us/arithmetic/SoftFloat-3e.zip"
JOBS="${JOBS:-$(nproc)}"

if [ "$(git -C "${QEMU_SRC}" rev-parse --abbrev-ref HEAD)" != "${QEMU_BRANCH}" ]; then
    git -C "${QEMU_SRC}" fetch --depth 1 origin "${QEMU_BRANCH}:${QEMU_BRANCH}"
    git -C "${QEMU_SRC}" checkout "${QEMU_BRANCH}"
fi
if [ ! -d "${LAO_SRC}" ]; then
    git clone --depth 1 -b "${LAO_BRANCH}" https://github.com/kalray/lao.git "${LAO_SRC}"
fi
mkdir -p "${BUILD}" "${PREFIX}/lib" "${PREFIX}/include"

# SoftFloat
SF_DIR="${BUILD}/softfloat"
if [ ! -f "${PREFIX}/lib/softfloat.a" ]; then
    mkdir -p "${SF_DIR}"
    [ -f "${SF_DIR}/SoftFloat-3e.zip" ] || curl -fL "${SOFTFLOAT_URL}" -o "${SF_DIR}/SoftFloat-3e.zip"
    (cd "${SF_DIR}" && unzip -qo SoftFloat-3e.zip)
    make -C "${SF_DIR}/SoftFloat-3e/build/Linux-x86_64-GCC" -j"${JOBS}"
    cp "${SF_DIR}/SoftFloat-3e/build/Linux-x86_64-GCC/softfloat.a" "${PREFIX}/lib/"
    cp "${SF_DIR}/SoftFloat-3e/source/include/softfloat.h" \
       "${SF_DIR}/SoftFloat-3e/source/include/softfloat_types.h" "${PREFIX}/include/"
fi

# LAO
mkdir -p "${BUILD}/lao"
(cd "${BUILD}/lao" && cmake "${LAO_SRC}/LAO" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DFAMILY="${LAO_SRC}/LAO/kvx" \
    -DTARGET=kv3 \
    -DYAML_ENABLED=off \
    -DGLPK_ENABLED=off \
    -DSOFTFLOAT_PREFIX="${PREFIX}" \
    -DKALRAY_INTERNAL="${PREFIX}/kalray_internal")
make -C "${BUILD}/lao" -j"${JOBS}"
make -C "${BUILD}/lao" install

# QEMU
mkdir -p "${BUILD}/qemu"
cd "${BUILD}/qemu"
"${QEMU_SRC}/configure" \
    --prefix="${PREFIX}" \
    --target-list=kvx-softmmu \
    --with-lao="${PREFIX}" \
    --disable-werror
if command -v ninja >/dev/null; then
    ninja
    ninja install
else
    make -j"${JOBS}"
    make install
fi

echo "Installed qemu-system-kvx in ${PREFIX}/bin"
