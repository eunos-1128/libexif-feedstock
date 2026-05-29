#!/bin/bash
set -euo pipefail

if [[ "${target_platform}" != "win-"* ]]; then
  # Get an updated config.sub and config.guess
  cp ${BUILD_PREFIX}/share/gnuconfig/config.* .
fi

./configure --prefix=${PREFIX} --disable-static --enable-shared --disable-nls --disable-dependency-tracking
make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  make check
fi
make install
