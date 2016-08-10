FROM alpine:3.4

RUN apk update

RUN apk add ca-certificates
RUN apk add git
RUN apk add gcc g++
RUN apk add autoconf
RUN apk add automake
RUN apk add make
RUN apk add musl-dev
RUN apk add perl
RUN apk add bison
RUN apk add flex
RUN apk add readline-dev
RUN apk add zlib-dev
RUN apk add file
RUN apk add xz

WORKDIR /tmp
RUN git clone https://github.com/NixOS/patchelf.git
RUN git clone -b REL9_5_STABLE https://github.com/postgres/postgres.git

ARG PREFIX

WORKDIR /tmp/patchelf
RUN ./bootstrap.sh
RUN LDFLAGS='-static -static-libgcc -static-libstdc++' ./configure --prefix=${PREFIX}
RUN make -j4 install

WORKDIR /tmp/postgres
RUN ./configure --prefix=${PREFIX}
RUN make -j4 install

RUN /bin/rm -rf ${PREFIX}/include ${PREFIX}/lib/pkgconfig ${PREFIX}/lib/pgxs ${PREFIX}/share/man ${PREFIX}/share/doc
RUN find ${PREFIX}/lib -type f -name '*.a'|xargs /bin/rm -f

RUN find ${PREFIX} -type f|xargs file|grep 'ELF 64-bit'|cut -d: -f1|xargs -n1 strip --strip-unneeded

ADD relocate.sh ${PREFIX}/bin/relocate.sh
RUN ${PREFIX}/bin/relocate.sh

RUN tar cf /tmp/postgres.tar ${PREFIX} && xz -e -9 /tmp/postgres.tar

WORKDIR ${PREFIX}

CMD /bin/sh

# vim:ts=4:sw=4:et:
