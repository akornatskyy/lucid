FROM akorn/nginx:stable-luajit2.1-alpine

MAINTAINER Andriy Kornatskyy <andriy.kornatskyy@live.com>

RUN set -ex \
    \
    && apk add --no-cache --virtual .build-deps \
        gcc \
        libc-dev \
        openssl-dev \
        git \
    \
    && for rock in lbase64 lua-cjson luacrypto struct ; do \
         luarocks install $rock ; \
       done \
    \
    && luarocks install --server=http://luarocks.org/dev lucid \
    \
    && apk del .build-deps \
    \
    && mkdir -p /app

WORKDIR /app

COPY nginx.conf /usr/local/nginx/conf
COPY helloworld.lua ./

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]