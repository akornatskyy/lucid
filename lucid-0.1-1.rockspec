package = 'lucid'
version = '0.1-1'

source = {
    url = '...'
}

dependencies = {
   'lua >= 5.1'
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
