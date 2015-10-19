local Cached = {}
local mt = {__index = Cached}

local function new(self)
    assert(self)
    assert(self.cache)
    return setmetatable(self, mt)
end

function Cached:get_or_set(key_factory, create_factory)
    assert(type(key_factory) == 'function')
    assert(type(create_factory) == 'function')
    return function(that, ...)
        local key = key_factory(...)
        local r = self.cache:get(key)
        if r ~= nil then
            return r
        end
        r = create_factory(that, ...)
        if r ~= nil then
            self.cache:set(key, r, self.time)
        end
        return r
    end
end

return {
    new = new
}
