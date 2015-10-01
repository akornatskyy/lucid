local setmetatable = setmetatable

local mt_call = function(cls)
	return setmetatable({}, cls)
end

local mt_call_ctor = function(cls, ...)
	local self = setmetatable({}, cls)
	cls.ctor(self, ...)
	return self
end

return function(base, cls)
    local mt = {}
    if cls then
        mt.__index = base
    else
        cls = base
    end
    cls.__index = cls
    cls = setmetatable(cls, mt)
    mt.__call = cls.ctor and mt_call_ctor or mt_call
    --cls.new = cls.ctor and mt_call_ctor or mt_call
    return cls
end
