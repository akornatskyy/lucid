local clock = require('socket').gettime
local assert, format = assert, string.format
local encoding = require 'core.encoding'
local digest = require 'security.crypto.digest'
local memcached = require 'libmemcached'

local hash = digest.new('sha256')
local encoder = encoding.new('base64').encode

local key_encode = function(key)
    return encoder(hash(key))
end

local key_encode2 = hash
local long_key = string.rep('key-', 75)

--local c = memcached.new('--server=127.0.0.1:11211 --binary-protocol',
--local c = memcached.new('--server=127.0.0.1:11211',
local c = memcached.new('--socket="/tmp/memcached.sock" --binary-protocol',
--local c = memcached.new('--socket="/tmp/memcached.sock"',
    encoding.json,
    --encoding.messagepack
    key_encode
)

--assert(memcached ~= memcached.status)
--assert(0 == memcached.status.OK)

local function timeit(name, f, n, k)
    print(name)
    n = n or 10000
    k = k or 3
    for j = 1, k do
        local t = clock()
        for i = 1, n do
            f()
        end
        t = clock() - t
        print(format(' #%d => %.1frps', j, n / t))
    end
end

local function bench()

    assert(c:set(long_key, 'Hello World!'))

    timeit('get (long key)', function()
        assert(c:get(long_key))
    end)

    timeit('set string', function()
        assert(c:set('key1', 'Hello World!'))
    end)

    timeit('get string', function()
        assert(c:get('key1'))
    end)

    timeit('set number', function()
        assert(c:set('key2', 100))
    end)

    timeit('get number', function()
        assert(c:get('key2'))
    end)

    timeit('incr', function()
        assert(c:incr('key2'))
    end)

    timeit('set table', function()
        assert(c:set('key3', {message='Hello World!'}))
    end)

    timeit('get table', function()
        assert(c:get('key3'))
    end)

    timeit('get multi', function()
        assert(c:get_multi({'key1', 'key2', 'key3', 'key4'}))
    end)
end

--assert(c:set('key1', 'Hello World!'))
--assert(c:touch('key1', 100))
--assert('Hello World!' == c:get('key1'))

assert(c:flush())
--print(key_encode(string.rep('key-', 75)))
assert(c:set(long_key, 'Hello World!'))
assert('Hello World!' == c:get(long_key))

assert(c:set('key1', 'Hello World!'))
assert('Hello World!' == c:get('key1'))
assert(c:set('key2', 100))
assert(100 == c:get('key2'))
assert(101 == c:incr('key2'))
assert(100 == c:decr('key2'))
assert(c:set('key3', {message='Hello World!'}))
assert('Hello World!' == c:get('key3').message)

assert(not c:get('key4'))
r = c:get_multi({'key4'})
assert(0 == #r)

assert(c:set('key4', ''))
--r = c:get_multi({'key1', 'key2'})
r = c:get_multi({'key1', 'key2', 'key4', 'key3', 'key5'})
assert('Hello World!' == r['key1'])
assert(100 == r['key2'])
assert('Hello World!' == r['key3'].message)
assert('' == r['key4'])
assert(nil == r['key5'])

assert(c:exist('key1'))
assert(c:delete('key1'))
assert(not c:exist('key1'))
assert(c:add('key1', 'x'))
assert(not c:add('key1', 'x'))
assert(c:replace('key1', 'x'))
assert(not c:replace('key5', 'x'))
assert(not c:delete('key5'))

-- a request that follows after touch fails in binary protocol if
-- key exists
--assert(c:touch('key1', 100))
assert(c:delete('key1'))
assert(not c:touch('key1', 100))
assert(not c:append('key1', 'x'))
assert(c:add('key1', ''))
assert(c:append('key1', '1;'))
assert(c:append('key1', '2;'))
assert(c:prepend('key1', '0;'))
assert('0;1;2;' == c:get('key1'))

bench()

assert(c:flush())
c:close()

--[[
local redis = require 'redis'
c = redis.connect('127.0.0.1', 6379)
assert(c:set('key1', 'Hello World!'))
assert('Hello World!' == c:get('key1'))

bench()
--]]
