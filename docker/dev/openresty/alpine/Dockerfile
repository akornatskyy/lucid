FROM openresty/openresty:alpine

LABEL maintainer="Andriy Kornatskyy <andriy.kornatskyy@live.com>"

ENV LUAROCKS_VERSION=3.7.0

RUN set -ex \
    \
    && apk add --no-cache --virtual .build-deps \
        curl \
        gcc \
        git \
        libc-dev \
        make \
        openssl-dev \
        outils-md5 \
        unzip \
    \
    && curl https://luarocks.github.io/luarocks/releases/luarocks-${LUAROCKS_VERSION}.tar.gz \
         | tar -xzf - \
    \
    && cd luarocks-${LUAROCKS_VERSION} \
    && ./configure \
         --with-lua=/usr/local/openresty/luajit \
         --lua-suffix=jit \
    && make build \
    && make install \
    && cd .. \
    && rm -rf luarocks-${LUAROCKS_VERSION} \
    \
    && for rock in lbase64 struct luaossl utf8; do \
         luarocks install --no-doc $rock ; \
       done \
    \
    && luarocks install --no-doc --dev lucid \
    \
    && rm -rf ~/.cache \
    && apk del .build-deps \
    \
    && find /lib -type f -name 'libcrypto*.so.*' | \
         xargs -I {} ln -sf {} /lib/libcrypto.so.1.0.0 \
    && find /lib -type f -name 'libssl*.so.*' | \
         xargs -I {} ln -sf {} /lib/libssl.so.1.0.0 \
    \
    && mkdir -p /app



WORKDIR /app

COPY nginx.conf /usr/local/openresty/nginx/conf
COPY helloworld.lua ./

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
