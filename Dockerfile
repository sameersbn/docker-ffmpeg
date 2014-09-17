FROM sameersbn/debian:jessie.20140918
MAINTAINER sameer@damagehead.com

RUN apt-get update \
 && apt-get install -y gcc make bzip2 libc6-dev libgnutls-dev libmp3lame-dev \
      libogg-dev libtheora-dev libvorbis-dev librtmp-dev libvpx-dev \
      libmpeg2-4-dev libxvidcore-dev libfaad-dev libmpg123-dev libmad0-dev \
      libjpeg-dev libpng12-dev libopus-dev libvo-aacenc-dev \
 && rm -rf /var/lib/apt/lists/* # 20140918

# install yasm, opus, vo-aacenc, x264, ffmpeg
RUN alias make="make -j$(awk '/^processor/ { N++} END { print N }' /proc/cpuinfo)" \
 && mkdir -p /tmp/yasm \
 && wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz -O - | tar -zxf - -C /tmp/yasm --strip=1 \
 && cd /tmp/yasm && ./configure --prefix=/usr && make && make install \
 && cd / && rm -rf /tmp/yasm \
 && mkdir -p /tmp/x264 \
 && wget "http://git.videolan.org/?p=x264.git;a=snapshot;h=HEAD;sf=tgz" -O - | tar -zxf - -C /tmp/x264 --strip=1 \
 && cd /tmp/x264 && ./configure --prefix=/usr --enable-shared --disable-opencl \
 && make && make install && cd / && rm -rf /tmp/x264 \
 && mkdir -p /tmp/ffmpeg/ \
 && wget "http://git.videolan.org/?p=ffmpeg.git;a=snapshot;h=HEAD;sf=tgz" -O - | tar zxf - --strip=1 -C /tmp/ffmpeg/ \
 && cd /tmp/ffmpeg/ \
 && ./configure --prefix=/usr --disable-static --enable-shared --enable-gpl --enable-nonfree \
      --enable-libx264 --enable-libmp3lame --enable-libvpx --enable-librtmp --enable-yasm \
      --enable-ffmpeg --enable-ffplay --enable-ffserver --enable-network --enable-gnutls \
      --enable-libopus --disable-debug --enable-libvo-aacenc --enable-version3 \
 && make && make install \
 && rm -rf /tmp/ffmpeg # 20140918
