FROM alpine:3.20.0 AS base

FROM base AS build
RUN apk add --no-cache build-base=0.5-r3 fftw-dev=3.3.10-r5 libpq-dev=16.3-r0 pcre2-dev=10.43-r0 sqlite-dev=3.45.3-r1 subversion
WORKDIR /tmp/src
RUN svn co -r 1784 svn://svn.savannah.gnu.org/apl/trunk . && ./configure --prefix=/tmp/build --without-gtk3 --without-x && make -j`nproc` && make install

FROM base AS app
COPY --from=build /usr/lib/libfftw3.so* /usr/lib/libgcc_s.so* /usr/lib/libncursesw.so* /usr/lib/libpcre2-32.so* /usr/lib/libpq.so* /usr/lib/libsqlite3.so* /usr/lib/libstdc++.so* /usr/lib/
COPY --from=build --link /tmp/build /usr/local/
RUN adduser -D user
USER user
WORKDIR /home/user
ENTRYPOINT ["/usr/local/bin/apl"]
