local setmetatable = setmetatable
_ENV = nil

local defaulttable = {
    __index = function(t, key)
        local i = t.default_factory()
        t[key] = i
        return i
    end
}

return function(default_factory)
    return setmetatable({default_factory=default_factory}, defaulttable)
end
