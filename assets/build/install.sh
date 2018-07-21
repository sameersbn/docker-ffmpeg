#!/bin/bash
set -e

install_packages() {
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
}

download_and_extract() {
  src=${1}
  dest=${2}
  tarball=$(basename ${src})

  if [[ ! -f ${FFMPEG_BUILD_ASSETS_DIR}/${tarball} ]]; then
    echo "Downloading ${1}..."
    wget ${src} -O ${FFMPEG_BUILD_ASSETS_DIR}/${tarball}
  fi

  echo "Extracting ${tarball}..."
  mkdir ${dest}
  tar xf ${FFMPEG_BUILD_ASSETS_DIR}/${tarball} --strip=1 -C ${dest}
}

strip_debug() {
  local dir=${1}
  local filter=${2}
  for f in $(find "${dir}" -name "${filter}")
  do
    if [[ -f ${f} ]]; then
      strip --strip-all ${f}
    fi
  done
}

# librtmp
install_packages libssl1.0-dev zlib1g-dev
download_and_extract "http://repo.or.cz/w/rtmpdump.git/snapshot/HEAD.tar.gz" "${FFMPEG_BUILD_ASSETS_DIR}/rtmpdump"
cd ${FFMPEG_BUILD_ASSETS_DIR}/rtmpdump
sed 's,prefix=/usr/local,prefix=/usr,' -i Makefile
sed 's,prefix=/usr/local,prefix=/usr,' -i librtmp/Makefile
make -j$(nproc)
make install
make DESTDIR=${FFMPEG_BUILD_ROOT_DIR} install

# x264
install_packages nasm
download_and_extract "http://ftp.videolan.org/pub/x264/snapshots/x264-${X264_VERSION}.tar.bz2" "${FFMPEG_BUILD_ASSETS_DIR}/x264"
cd ${FFMPEG_BUILD_ASSETS_DIR}/x264
./configure \
  --prefix=/usr \
  --enable-shared \
  --disable-opencl
make -j$(nproc)
make install
make DESTDIR=${FFMPEG_BUILD_ROOT_DIR} install

# ffmpeg
download_and_extract "http://www.ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2" "${FFMPEG_BUILD_ASSETS_DIR}/ffmpeg"
cd ${FFMPEG_BUILD_ASSETS_DIR}/ffmpeg
./configure \
  --prefix=/usr \
  --disable-static \
  --enable-shared \
  --enable-gpl \
  --enable-nonfree \
  --enable-yasm \
  --enable-libx264 \
  --enable-librtmp \
  --enable-ffmpeg \
  --enable-ffplay \
  --enable-network \
  --disable-debug \
  --enable-version3
make -j$(nproc)
make DESTDIR=${FFMPEG_BUILD_ROOT_DIR} install

strip_debug "${FFMPEG_BUILD_ROOT_DIR}/usr/bin/" "*"
strip_debug "${FFMPEG_BUILD_ROOT_DIR}/usr/sbin/" "*"
strip_debug "${FFMPEG_BUILD_ROOT_DIR}/usr/lib/" "*.so"
strip_debug "${FFMPEG_BUILD_ROOT_DIR}/usr/lib/" "*.so.*"

rm -rf ${FFMPEG_BUILD_ROOT_DIR}/usr/lib/*.a
rm -rf ${FFMPEG_BUILD_ROOT_DIR}/usr/lib/pkgconfig
rm -rf ${FFMPEG_BUILD_ROOT_DIR}/usr/share/man
rm -rf ${FFMPEG_BUILD_ROOT_DIR}/usr/share/include
