#!/bin/bash
set -euo pipefail

# Get an updated config.sub and config.guess
cp ${BUILD_PREFIX}/share/gnuconfig/config.* .

AUTOPOINT=true autoreconf -vfi
./configure --prefix=${PREFIX} --disable-static --enable-shared --enable-pic --disable-nls --disable-dependency-tracking
make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  make check
fi
make install
