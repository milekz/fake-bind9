FROM alpine

RUN set -ex \
    && export BINDVERSION=9.14.2 \
    && apk upgrade --update \
    && apk add --virtual .bind9-builddeps postgresql-dev  build-base bash curl libressl-dev  libcap-dev perl linux-headers bsd-compat-headers libxml2-dev go git musl-dev json-c-dev  python3 py3-pip  \
    && apk add --virtual .bind9-deps libxml2 libcap libgcc s6 json-c libpq \
    && pip3 install ply \
    && curl -sSL https://ftp.isc.org/isc/bind9/$BINDVERSION/bind-$BINDVERSION.tar.gz | tar xz \
    && cd bind-$BINDVERSION \
       && CFLAGS="-O3" ./configure  --prefix=/usr/local/bind9 --enable-largefile   \
          --exec-prefix=/usr/local/bind9 --with-libxml2 --with-libjson --with-libtool --enable-static=no \
          --enable-full-report   --with-dlz-postgres=yes  \
       && make \
       && make install \
       && bash -c 'rm -rf /usr/local/bind9/{include,share}' \
       && bash -c 'strip /usr/local/bind9/{bin,sbin,lib}/* || exit 0' \
    && cd .. \
    && rm -rf bind-$BINDVERSION \
    && mkdir /gobuild \
       && export GOPATH=/gobuild \
       && go get -ldflags="-s -w" github.com/adnanh/webhook \
       && install -m 755 /gobuild/bin/webhook /usr/local/bin/webhook \
       && rm -rf /gobuild /usr/lib/go \
    && apk del --purge .bind9-builddeps \
    && apk add bash \
    && rm -rf /var/cache/apk/* \
    && /usr/local/bind9/sbin/rndc-confgen -a \
    && echo 'include "/etc/bind/named.conf";' > /usr/local/bind9/etc/named.conf

ADD files /etc/
ADD files/start.sh /
VOLUME /etc/bind/
EXPOSE 53/udp 53/tcp 9000/tcp
HEALTHCHECK CMD nslookup google.com 127.0.0.1 || exit 1

CMD [ "/start.sh" ]
