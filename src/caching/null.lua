local Cache = {}
local mt = {__index = Cache}

local function new()
    return setmetatable({}, mt)
end

function Cache:add(key, value, expiration)
    assert(type(key) == 'string')
    assert(value ~= nil)
    assert(expiration == nil or type(expiration) == 'number')
    return true
end

function Cache:set(key, value, expiration)
    assert(type(key) == 'string')
    assert(value ~= nil)
    assert(expiration == nil or type(expiration) == 'number')
    return true
end

function Cache:replace(key, value, expiration)
    assert(type(key) == 'string')
    assert(value ~= nil)
    assert(expiration == nil or type(expiration) == 'number')
    return true
end

function Cache:get(key)
    assert(type(key) == 'string')
    return nil
end

function Cache:get_multi(keys)
    assert(type(keys) == 'table')
    return {}
end

function Cache:append(key, value)
    assert(type(key) == 'string')
    assert(type(value) == 'string')
    return true
end

function Cache:prepend(key, value)
    assert(type(key) == 'string')
    assert(type(value) == 'string')
    return true
end

function Cache:delete(key)
    assert(type(key) == 'string')
    return true
end

function Cache:touch(key, expiration)
    assert(type(key) == 'string')
    assert(expiration == nil or type(expiration) == 'number')
    return true
end

function Cache:incr(key, offset)
    assert(type(key) == 'string')
    assert(type(offset) == 'number')
    return true
end

function Cache:decr(key, offset)
    assert(type(key) == 'string')
    assert(type(offset) == 'number')
    return true
end

function Cache:exist(key)
    assert(type(key) == 'string')
    return false
end

return {
    new = new
}
