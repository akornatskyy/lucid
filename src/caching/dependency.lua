local setmetatable = setmetatable

local Dependency = {}
local mt = {__index=Dependency}

function Dependency:next_key(master_key)
end

function Dependency:add(master_key, key)
end

function Dependency:delete(master_key)
end

local function new(cache, time)
    return setmetatable({cache=cache, time=time}, mt)
end

return {
    new = new
}
