package = 'lucid-caching'

version = '1.0-1'

description = {
    summary = '',
    homepage = 'https://github.com/akornatskyy/lucid',
    maintainer = 'Andriy Kornatskyy <andriy.kornatskyy@live.com>',
    license = 'MIT'
}

dependencies = {
   'lua >= 5.1'
}

source = {
    url = 'git://github.com/akornatskyy/lucid.git'
}

external_dependencies = {
    LIBMEMCACHED = {
        header = 'libmemcached/memcached.h'
    }
}

build = {
    type = 'builtin',

    modules = {
        ['libmemcached'] = {
            sources = {'src/caching/libmemcached.c'},
            libraries = {'memcached'},
            incdirs = {'$(LIBMEMCACHED_INCDIR)'},
            libdirs = {'$(LIBMEMCACHED_LIBDIR)'}
        }
    }
}
