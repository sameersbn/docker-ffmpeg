#!/bin/bash
set -e

apt-get update

# install build dependencies
apt-get install -y gcc make yasm bzip2 \
  libc6-dev libgnutls-dev libogg-dev libjpeg-dev libpng12-dev \
  libvpx-dev libtheora-dev libxvidcore-dev libmpeg2-4-dev libssl-dev \
  libvorbis-dev libfaad-dev libmp3lame-dev libmpg123-dev libmad0-dev libopus-dev libvo-aacenc-dev

# use all available processor cores for the build
alias make="make -j$(nproc)"

# compile rtmpsuck
mkdir -p /tmp/rtmpdump
wget "http://repo.or.cz/w/rtmpdump.git/snapshot/HEAD.tar.gz" -O - | tar -zxf - -C /tmp/rtmpdump --strip=1
cd /tmp/rtmpdump/
sed 's,prefix=/usr/local,prefix=/usr,' -i Makefile
sed 's,prefix=/usr/local,prefix=/usr,' -i librtmp/Makefile
make && make install

# compile x264
wget "http://ftp.videolan.org/pub/x264/snapshots/x264-${X264_VERSION}.tar.bz2" -O /tmp/x264-${X264_VERSION}.tar.bz2
mkdir -p /tmp/x264
cd /tmp/x264 && ./configure --prefix=/usr --enable-shared --disable-opencl
make && make install

# compile ffmpeg
mkdir -p /tmp/ffmpeg/
wget "http://www.ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2" -O - | tar -jxf - -C /tmp/ffmpeg/ --strip=1
cd /tmp/ffmpeg/
./configure --prefix=/usr --disable-static --enable-shared --enable-gpl --enable-nonfree \
  --enable-libx264 --enable-libmp3lame --enable-libvpx --enable-librtmp --enable-yasm \
  --enable-ffmpeg --enable-ffplay --enable-ffserver --enable-network --enable-gnutls \
  --enable-libopus --disable-debug --enable-libvo-aacenc --enable-version3
make && make install

# purge build dependencies, don't need 'em anymore
apt-get purge -y --auto-remove gcc make yasm bzip2 \
  libc6-dev libgnutls-dev libogg-dev librtmp-dev libjpeg-dev libpng12-dev \
  libvpx-dev libtheora-dev libxvidcore-dev libmpeg2-4-dev libssl-dev \
  libvorbis-dev libfaad-dev libmp3lame-dev libmpg123-dev libmad0-dev libopus-dev libvo-aacenc-dev

# cleanup
rm -rf /tmp/rtmpdump.tar.gz /tmp/rtmpdump/
rm -rf /tmp/x264-snapshot-${X264_VERSION}.tar.bz2 /tmp/x264
rm -rf /tmp/ffmpeg-${FFMPEG_VERSION}.tar.bz2 /tmp/ffmpeg
rm -rf /var/lib/apt/lists/*
