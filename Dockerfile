FROM alpine:latest
ARG user=ignis
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories
RUN apk update && apk add crystal shards libevent-dev g++ gc-dev \
                          libc-dev libevent-dev libxml2-dev llvm llvm-dev \
                          llvm-static make pcre-dev readline-dev \
                          yaml-dev zlib-dev zlib llvm-libs git perl
RUN git clone https://github.com/openssl/openssl.git
WORKDIR /openssl
RUN git checkout OpenSSL_1_0_2-stable \
  && ./config no-shared no-unit-test && make -j5
RUN adduser -D $user
