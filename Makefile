.SILENT: env test clean qa
.PHONY: env test clean qa

ENV=$(shell pwd)/env
#LUA=$(shell which lua)
#LUA_VERSION=$(shell $(LUA) -e 'print(_VERSION:match("%d.%d"))')
LUA=$(ENV)/bin/lua
LUA_VERSION=5.1.5
#LUA_INCLUDE_PATH=$(shell dirname $(LUA))/../include
LUA_ROCKS_VERSION=2.2.2

CFLAGS=-pipe -O2 -fPIC -std=c99 -Wall -Wextra -Wshadow -Wpointer-arith -Wstrict-prototypes -Wmissing-prototypes -Wdeclaration-after-statement -Wno-unused-parameter -Wconditional-uninitialized -Werror
#CFLAGS=


env:
	rm -rf $(ENV) ; mkdir -p $(ENV) ; \
	wget -c http://www.lua.org/ftp/lua-$(LUA_VERSION).tar.gz \
		-O - | tar -xzf - ; \
	cd lua-$(LUA_VERSION) ; \
	sed -i.bak s%/usr/local%$(ENV)%g src/luaconf.h ; \
	sed -i.bak s%./?.lua\;%./?.lua\;./src/?.lua\;%g src/luaconf.h ; \
	make -s macosx install INSTALL_TOP=$(ENV) ; \
	cd .. ; rm -rf lua-$(LUA_VERSION) ; \
	wget -c http://luarocks.org/releases/luarocks-$(LUA_ROCKS_VERSION).tar.gz \
		-O - | tar -xzf - ; \
	cd luarocks-$(LUA_ROCKS_VERSION) ; \
	./configure --prefix=$(ENV) --with-lua=$(ENV) --sysconfdir=$(ENV) \
		--force-config && \
	make -s build install && \
	cd .. ; rm -rf luarocks-$(LUA_ROCKS_VERSION) ; \
	for rock in busted luacov luacheck lbase64 struct luacrypto lua-cjson; do \
		$(ENV)/bin/luarocks --deps-mode=one install $$rock ; \
	done

debian:
	apt-get install build-essential unzip libncurses5-dev libreadline6-dev \
		libssl-dev

test:
	$(ENV)/bin/busted

mc:
	$(ENV)/bin/luarocks make CFLAGS='$(CFLAGS)' LIBMEMCACHED_DIR=/opt/local

clean:
	find src/ -name '*.o' -delete
	rm -rf luacov.* luac.out *.so

qa:
	$(ENV)/bin/luacheck -q src/ spec/ demos/

nginx:
	cd env ; \
	git clone https://github.com/openresty/lua-nginx-module ; \
	hg clone http://hg.nginx.org/nginx ; \
	cd nginx ; \
	export LUAJIT_LIB=/opt/local/lib ; \
	export LUAJIT_INC=/opt/local/include/luajit-2.0/ ; \
	auto/configure --prefix=./ --add-module=../lua-nginx-module ; \
	make -j4 ; \
	mkdir logs ; \
	ln -s ../../../etc/nginx.conf conf/lucid.conf
