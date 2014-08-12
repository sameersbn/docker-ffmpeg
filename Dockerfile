FROM sameersbn/ubuntu:12.04.20140812
MAINTAINER sameer@damagehead.com

RUN apt-get update && \
		apt-get install -y make bzip2 pkg-config libgnutls-dev libmp3lame-dev \
			libogg-dev libtheora-dev libvorbis-dev librtmp-dev libvpx-dev \
			libmpeg2-4-dev libxvidcore-dev libfaad-dev libmpg123-dev libmad0-dev \
			libjpeg-dev libpng12-dev && \
		apt-get clean # 20140704

# install yasm, opus, vo-aacenc, x264, ffmpeg
RUN alias make="make -j$(awk '/^processor/ { N++} END { print N }' /proc/cpuinfo)" && \
		mkdir -p /tmp/yasm && \
		wget http://anduin.linuxfromscratch.org/sources/BLFS/svn/y/yasm-1.2.0.tar.gz -O - | tar -zxf - -C /tmp/yasm --strip=1 && \
		cd /tmp/yasm && ./configure --prefix=/usr && make && make install && \
		cd / && rm -rf /tmp/yasm && \
		mkdir -p /tmp/opus && \
		wget http://downloads.xiph.org/releases/opus/opus-1.1.tar.gz -O - | tar -zxf - -C /tmp/opus --strip=1 && \
		cd /tmp/opus && ./configure --prefix=/usr --disable-static --enable-shared && \
		make && make install && \
		cd / && rm -rf /tmp/opus && \
		mkdir -p /tmp/vo-aacenc && \
		wget http://prdownloads.sourceforge.net/opencore-amr/vo-aacenc-0.1.3.tar.gz -O - | tar -zxf - -C /tmp/vo-aacenc --strip=1 && \
		cd /tmp/vo-aacenc && \
		./configure --prefix=/usr --disable-static --enable-shared && \
		make && make install && \
		cd / && rm -rf /tmp/vo-aacenc && \
		mkdir -p /tmp/x264 && \
		wget "http://git.videolan.org/?p=x264.git;a=snapshot;h=d6b4e63d2ed8d444b77c11b36c1d646ee5549276;sf=tgz" -O - | tar -zxf - -C /tmp/x264 --strip=1 && \
		cd /tmp/x264 && ./configure --prefix=/usr --enable-shared --disable-opencl && \
		make && make install && cd / && rm -rf /tmp/x264 && \
		mkdir -p /tmp/ffmpeg/ && \
		wget "http://git.videolan.org/?p=ffmpeg.git;a=snapshot;h=1bec8ce91107198e2099b2ef40cda5271a7ab853;sf=tgz" -O - | tar zxf - --strip=1 -C /tmp/ffmpeg/ && \
		cd /tmp/ffmpeg/ && \
		./configure --prefix=/usr --disable-static --enable-shared --enable-gpl --enable-nonfree \
			--enable-libx264 --enable-libmp3lame --enable-libvpx --enable-librtmp --enable-yasm \
			--enable-ffmpeg --enable-ffplay --enable-ffserver --enable-network --enable-gnutls \
			--enable-libopus --disable-debug --enable-libvo-aacenc --enable-version3 && \
		make && make install && rm -rf /tmp/ffmpeg # 20140812
