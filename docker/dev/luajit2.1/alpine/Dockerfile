FROM akorn/nginx:stable-luajit2.1-alpine

LABEL maintainer="Andriy Kornatskyy <andriy.kornatskyy@live.com>"

RUN set -ex \
    \
    && apk add --no-cache --virtual .build-deps \
        gcc \
        git \
        libc-dev \
        openssl-dev \
        unzip \
    \
    && for rock in lbase64 lua-cjson luaossl struct utf8; do \
         luarocks install --no-doc $rock ; \
       done \
    \
    && luarocks install --no-doc --server=http://luarocks.org/dev lucid \
    \
    && rm -rf ~/.cache \
    && apk del .build-deps \
    \
    && mkdir -p /app

WORKDIR /app

COPY nginx.conf /usr/local/nginx/conf
COPY helloworld.lua ./

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
