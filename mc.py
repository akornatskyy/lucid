import pylibmc
from time import time as clock


def timeit(name, f, n=10000, k=3):
    print(name)
    for j in xrange(k):
        t = clock()
        for i in xrange(n):
            f()
        t = clock() - t
        print(' #%d => %.1frps' % (j + 1, n / t))


#s = '127.0.0.1'
s = '/tmp/memcached.sock'

c = pylibmc.Client([s], binary=True) #, behaviors={'tcp_nodelay': True})

# region: test cases

#import redis
#c = redis.StrictRedis(host='localhost', port=6379, db=0)

#c.set('key1', 'Hello World!')
#c.touch('key1', 100)
#assert 'Hello World!' == c.get('key1')

if 1:
    timeit('set string', lambda: c.set('key1', 'Hello World!'))
    timeit('get string', lambda: c.get('key1'))
    timeit('set number', lambda: c.set('key2', 100))
    timeit('get number', lambda: c.get('key2'))
    timeit('incr', lambda: c.incr('key2'))
    timeit('set dict', lambda: c.set('key3', {'message': 'Hello World!'}))
    timeit('get dict', lambda: c.get('key3'))
    c.set('key4', '')
    timeit('get multi', lambda: c.get_multi(('key1', 'key2', 'key3', 'key4',
                                             'key5')))
