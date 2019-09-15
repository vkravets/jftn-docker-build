FROM praekeltfoundation/alpine-buildpack-deps:3.8 as thrift-builder

# install bats for testing
# TODO: make this from Circle CI
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

# Install thrift build dependecies
RUN apk add --no-cache \
    automake bison flex boost boost-dev boost-unit_test_framework libevent-dev pkgconfig python3-dev python2-dev

RUN cd /tmp && \
    curl http://archive.apache.org/dist/thrift/0.12.0/thrift-0.12.0.tar.gz | tar zx &&  \
    cd thrift-0.12.0 && \
    ./configure --prefix=/tmp/thrift-build && \
    make && \
    make install && \
    cd .. && rm -rf thrift-0.12.0

FROM alpine:3.8
RUN apk --no-cache add ca-certificates

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

# Install nodejs from repo
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/main \
    nodejs

# Install java
RUN set -x \
	&& apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community \
		openjdk8="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

COPY --from=thrift-builder /tmp/thrift-build /usr/local

RUN addgroup -S jftn-build && adduser -S jftn-build -G jftn-build
USER jftn-build
