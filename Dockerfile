FROM praekeltfoundation/alpine-buildpack-deps:3.8

# install bats for testing
RUN git clone https://github.com/sstephenson/bats.git \
  && cd bats \
  && ./install.sh /usr/local \
  && cd .. \
  && rm -rf bats

RUN export PERL_MM_USE_DEFAULT=1

RUN apk add --no-cache perl-utils perl-dev
RUN set -x && cpan install  Getopt::Long \
                            Pod::Usage \
                            TAP::Parser \
                            Time::HiRes \
                            XML::Generator

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u222
ENV JAVA_ALPINE_VERSION 8.222.10-r1

# Install node
# ENV NODE_VERSION=v8.11.2 NPM_VERSION=5 YARN_VERSION=latest
# ENV VERSION=v10.1.0 NPM_VERSION=6 YARN_VERSION=latest


# For base builds
#ENV CONFIG_FLAGS="--fully-static --without-npm"

#RUN apk add --no-cache binutils-gold && \
#  for server in ipv4.pool.sks-keyservers.net keyserver.pgp.com ha.pool.sks-keyservers.net; do \
#    gpg --keyserver $server --recv-keys \
#      94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
#      FD3A5288F042B6850C66B31F09FE44734EB7990E \
#      71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
#      DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
#      C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
#      B9AE9905FFD7803F25714661B63B535A4C206CA9 \
#      56730D5401028683275BD23C23EFEFE93C4CFFFE \
#      77984A986EBC2AA786BC0F66B01FBB92821C587A && break; \
#  done && \
#  curl -sfSLO https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}.tar.xz && \
#  curl -sfSL https://nodejs.org/dist/${NODE_VERSION}/SHASUMS256.txt.asc | gpg --batch --decrypt | \
#    grep " node-${NODE_VERSION}.tar.xz\$" | sha256sum -c | grep ': OK$' && \
#  tar -xf node-${NODE_VERSION}.tar.xz && \
#  cd node-${NODE_VERSION} && \
#  ./configure --prefix=/usr ${CONFIG_FLAGS} && \
#  make -j$(getconf _NPROCESSORS_ONLN) && \
#  make install && \
#  cd / && \
#  if [ -z "$CONFIG_FLAGS" ]; then \
#    if [ -n "$NPM_VERSION" ]; then \
#      npm install -g npm@${NPM_VERSION}; \
#    fi; \
#    find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf; \
#    if [ -n "$YARN_VERSION" ]; then \
#      for server in ipv4.pool.sks-keyservers.net keyserver.pgp.com ha.pool.sks-keyservers.net; do \
#        gpg --keyserver $server --recv-keys \
#          6A010C5166006599AA17F08146C2130DFD2497F5 && break; \
#      done && \
#      curl -sfSL -O https://yarnpkg.com/${YARN_VERSION}.tar.gz -O https://yarnpkg.com/${YARN_VERSION}.tar.gz.asc && \
#      gpg --batch --verify ${YARN_VERSION}.tar.gz.asc ${YARN_VERSION}.tar.gz && \
#      mkdir /usr/local/share/yarn && \
#      tar -xf ${YARN_VERSION}.tar.gz -C /usr/local/share/yarn --strip 1 && \
#      ln -s /usr/local/share/yarn/bin/yarn /usr/local/bin/ && \
#      ln -s /usr/local/share/yarn/bin/yarnpkg /usr/local/bin/ && \
#      rm ${YARN_VERSION}.tar.gz*; \
#    fi; \
#  fi && \
#  rm -rf /node-${VERSION}*  /tmp/* /var/cache/apk/* \
#    /usr/lib/node_modules/npm/man \
#    /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html /usr/lib/node_modules/npm/scripts

# Install nodejs from repo
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/main \
    nodejs

# Install java
RUN set -x \
	&& apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community \
		openjdk8="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

# Install maven
# RUN apk add --no-cache maven

# Install thrift build dependecies
RUN apk add --no-cache \
    automake bison flex boost boost-dev boost-unit_test_framework libevent-dev pkgconfig python3-dev python2-dev

RUN cd /tmp && \
    curl http://archive.apache.org/dist/thrift/0.12.0/thrift-0.12.0.tar.gz | tar zx &&  \
    cd thrift-0.12.0 && \
    ./configure && \
    make && \
    make install && \
    cd .. && rm -rf thrift-0.12.0
