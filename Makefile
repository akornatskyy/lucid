.SILENT: env test clean qa nginx run
.PHONY: env test clean qa nginx run

ENV=$(shell pwd)/env
#LUA=$(shell which lua)
#LUA_VERSION=$(shell $(LUA) -e 'print(_VERSION:match("%d.%d"))')
LUA_IMPL=
LUA_VERSION=5.1.5
PLATFORM=macosx
#LUA_INCLUDE_PATH=$(shell dirname $(LUA))/../include
LUA_ROCKS_VERSION=2.2.2
NGINX_VERSION=1.9.5
NGINX_LUA_MODULE_VERSION=0.9.16

CFLAGS=-pipe -O2 -fPIC -std=c99 -Wall -Wextra -Wshadow -Wpointer-arith -Wstrict-prototypes -Wmissing-prototypes -Wdeclaration-after-statement -Wno-unused-parameter -Wconditional-uninitialized -Werror
#CFLAGS=


env:
	rm -rf $(ENV) ; mkdir -p $(ENV) ; \
	unset LUA_PATH ; unset LUA_CPATH ; \
	if [ "$(LUA_IMPL)" = "luajit" ] ; then \
		wget -c http://luajit.org/download/LuaJIT-$(LUA_VERSION).tar.gz \
			-O - | tar xzf - ; \
	  	cd LuaJIT-$(LUA_VERSION) ; \
	  	sed -i.bak s%/usr/local%$(ENV)%g src/luaconf.h ; \
		sed -i.bak s%./?.lua\"%./?.lua\;./src/?.lua\"%g src/luaconf.h ; \
		export MACOSX_DEPLOYMENT_TARGET=10.10 ; \
	    make -s install PREFIX=$(ENV) INSTALL_INC=$(ENV)/include ; \
		ln -sf luajit-$(LUA_VERSION) $(ENV)/bin/lua ; \
		cd .. ; rm -rf luajit-$(LUA_VERSION) ; \
	else \
		wget -c http://www.lua.org/ftp/lua-$(LUA_VERSION).tar.gz \
			-O - | tar -xzf - ; \
		cd lua-$(LUA_VERSION) ; \
		sed -i.bak s%/usr/local%$(ENV)%g src/luaconf.h ; \
		sed -i.bak s%./?.lua\;%./?.lua\;./src/?.lua\;%g src/luaconf.h ; \
		make -s $(PLATFORM) install INSTALL_TOP=$(ENV) ; \
		cd .. ; rm -rf lua-$(LUA_VERSION) ; \
	fi ; \
	wget -c http://luarocks.org/releases/luarocks-$(LUA_ROCKS_VERSION).tar.gz \
		-O - | tar -xzf - ; \
	cd luarocks-$(LUA_ROCKS_VERSION) ; \
	./configure --prefix=$(ENV) --with-lua=$(ENV) --sysconfdir=$(ENV) \
		--force-config && \
	make -s build install && \
	cd .. ; rm -rf luarocks-$(LUA_ROCKS_VERSION) ; \
	for rock in busted luacov luacheck lbase64 struct luacrypto lua-cjson; do \
		$(ENV)/bin/luarocks --deps-mode=one install $$rock ; \
	done ; \
	ln -sf `pwd`/bin/lurl $(ENV)/bin/lurl

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
	WDIR=`pwd` ; \
	cd $(ENV) ; \
	rm -rf nginx* lua-nginx-module* ; \
	wget -c https://github.com/openresty/lua-nginx-module/archive/v$(NGINX_LUA_MODULE_VERSION).tar.gz \
			-O - | tar xzf - ; \
	ln -sf lua-nginx-module-$(NGINX_LUA_MODULE_VERSION) lua-nginx-module ; \
	wget -c http://nginx.org/download/nginx-$(NGINX_VERSION).tar.gz \
			-O - | tar xzf - ; \
	ln -sf nginx-$(NGINX_VERSION) nginx ; \
	if [ "$(LUA_IMPL)" = "luajit" ] ; then \
		export LUAJIT_LIB=$(ENV)/lib ; \
		export LUAJIT_INC=$(ENV)/include ; \
	else \
		export LUA_LIB=$(ENV)/lib ; \
		export LUA_INC=$(ENV)/include ; \
	fi ; \
	cd nginx ; \
	./configure --prefix=./ --without-http_rewrite_module --without-pcre \
		--add-module=../lua-nginx-module ; \
	make -j4 ; \
	mkdir -p logs ; \
	ln -sf $$WDIR/etc/nginx.conf conf/lucid.conf

run:
	cd $(ENV)/nginx ; objs/nginx -c conf/lucid.conf
