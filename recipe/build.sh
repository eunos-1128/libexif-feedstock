#!/bin/bash
set -exo pipefail

if [[ "${target_platform}" != "win-"* ]]; then
  # Get an updated config.sub and config.guess
  cp ${BUILD_PREFIX}/share/gnuconfig/config.* .
fi

./configure --prefix=${PREFIX} --disable-static --enable-shared --disable-nls --disable-dependency-tracking

if [[ "${target_platform}" == win-* ]]; then
    patch_libtool
    # `-export-symbols` is not supported by lld-link on Windows;
    # replace with `-export-symbols-regex` to export all symbols
    # Also add `-avoid-version` to generate exif.dll instead of exif-12.dll
    sed -i.bak \
        -e 's|-export-symbols $(srcdir)/libexif.sym|-export-symbols-regex ".*"|g' \
        -e 's|-version-info [0-9]*:[0-9]*:[0-9]*|-avoid-version|g' \
        libexif/Makefile
fi

make -j${CPU_COUNT}

if [[ "${target_platform}" != "win-"* && "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  make check
fi

make install

if [[ "${target_platform}" == "win-"* ]]; then
    # Rename import library to follow MSVC naming convention
    mv "${PREFIX}/lib/exif.dll.lib" "${PREFIX}/lib/exif.lib"
fi
