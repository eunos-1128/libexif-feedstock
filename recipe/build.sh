#!/bin/bash
set -euo pipefail

if [[ "${target_platform}" != "win-"* ]]; then
  # Get an updated config.sub and config.guess
  cp ${BUILD_PREFIX}/share/gnuconfig/config.* .
fi

./configure --prefix=${PREFIX} --disable-static --enable-shared --disable-nls --disable-dependency-tracking

if [[ "${target_platform}" == "win-"* ]]; then
    # `patch_libtool` only patches the libtool in the current directory;
    # run it in each subdirectory that contains a libtool script
    for lt in $(find . -name "libtool" ! -name "*.bak"); do
        pushd "$(dirname "$lt")"
        patch_libtool
        popd
    done
fi

make -j${CPU_COUNT}

if [[ "${target_platform}" != "win-"* && "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  make check
fi

make install
