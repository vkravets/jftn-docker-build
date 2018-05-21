FROM praekeltfoundation/alpine-buildpack-deps:3.7

# install bats for testing
RUN git clone https://github.com/sstephenson/bats.git \
  && cd bats \
  && ./install.sh /usr/local \
  && cd .. \
  && rm -rf bats

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

ENV JAVA_VERSION 8u151
ENV JAVA_ALPINE_VERSION 8.151.12-r0

# Install java
RUN set -x \
	&& apk add --no-cache \
		openjdk8="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

# Install maven
# RUN apk add --no-cache maven

# Install thrift build dependecies
RUN apk add --no-cache \
    automake bison flex boost boost-dev libevent-dev pkgconfig

RUN cd /tmp && \
    curl http://archive.apache.org/dist/thrift/0.11.0/thrift-0.11.0.tar.gz | tar zx &&  \
    cd thrift-0.11.0 && \
    ./configure && \
    make && \
    make install && \
    cd .. && rm -rf thrift-0.11.0
