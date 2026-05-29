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
    sed -i.bak 's|-export-symbols $(srcdir)/libexif.sym|-export-symbols-regex ".*"|g' libexif/Makefile
fi

make -j${CPU_COUNT}

if [[ "${target_platform}" != "win-"* && "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  make check
fi

make install

if [[ "${target_platform}" == "win-"* ]]; then
    mv "${PREFIX}"/bin/exif-*.dll "${PREFIX}/bin/exif.dll"
    mv "${PREFIX}/lib/exif.dll.lib" "${PREFIX}/lib/exif.lib"
fi
