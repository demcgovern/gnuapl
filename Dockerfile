FROM alpine:3.18.3 AS base
ENV apkbuildbaseversion=0.5-r3
ENV apkfftwversion=3.3.10-r2
ENV apklibpqversion=15.4-r0
ENV apkpcre2version=10.42-r1
ENV apksqliteversion=3.41.2-r2
ENV buildconfigureoptions="--without-gtk3 --without-x"
ENV buildsourcerevision=1725
ENV buildsourceuri=svn://svn.savannah.gnu.org/apl/trunk
ENV buildsourceversion=1.8
LABEL apk.build-base.version=${apkbuildbaseversion}
LABEL apk.fftw-dev.version=${apkfftwversion}
LABEL apk.libpq-dev.version=${apklibpqversion}
LABEL apk.pcre2-dev.version=${apkpcre2version}
LABEL apk.sqlite-dev.version=${apksqliteversion}
LABEL build.configure.options=${buildconfigureoptions}
LABEL build.source.uri=${buildsourceuri}
LABEL build.source.revision=${buildsourcerevision}
LABEL build.source.version=${buildsourceversion}
FROM base AS build
RUN apk add --no-cache \
build-base=${apkbuildbaseversion} \
fftw-dev=${apkfftwversion} \
libpq-dev=${apklibpqversion} \
pcre2-dev=${apkpcre2version} \
sqlite-dev=${apksqliteversion} \
subversion
WORKDIR /tmp/src
RUN svn co -r ${buildsourcerevision} ${buildsourceuri} . \
&& ./configure --prefix=/tmp/build ${buildconfigureoptions} \
&& make -j`nproc` \
&& make install
FROM base AS app
COPY --from=build \
/usr/lib/libfftw3.so* \
/usr/lib/libgcc_s.so* \
/usr/lib/libncursesw.so* \
/usr/lib/libpcre2-32.so* \
/usr/lib/libpq.so* \
/usr/lib/libsqlite3.so* \
/usr/lib/libstdc++.so* \
/usr/lib/
COPY --from=build --link /tmp/build /usr/local/
RUN adduser -D user
USER user
WORKDIR /home/user
ENTRYPOINT ["/usr/local/bin/apl"]
