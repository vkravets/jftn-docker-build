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

ENV JAVA_VERSION 8u292
ENV JAVA_ALPINE_VERSION 8.292.10-r0
ENV THRIFT_VERSION 0.14.1-r0

# Install nodejs from repo
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/main \
    nodejs

# Install java
RUN set -x \
	&& apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community \
		openjdk8="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

# Install thrift
RUN set -x \
	&& apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing \
		thrift="$THRIFT_VERSION"

RUN addgroup -S jftn-build && adduser -S jftn-build -G jftn-build
USER jftn-build
