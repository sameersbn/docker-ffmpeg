FROM sameersbn/ubuntu:14.04.20150323
MAINTAINER sameer@damagehead.com

RUN apt-get update \
 && apt-get install -y bzip2 libgnutlsxx27 libogg0 libjpeg8 libpng12-0 \
      libvpx1 libtheora0 libxvidcore4 libmpeg2-4 \
      libvorbis0a libfaad2 libmp3lame0 libmpg123-0 libmad0 libopus0 libvo-aacenc0 \
 && rm -rf /var/lib/apt/lists/* # 20150323

ADD install /install
RUN chmod 755 /install
RUN /install
