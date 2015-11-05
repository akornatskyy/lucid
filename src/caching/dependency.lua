local setmetatable = setmetatable

local Dependency = {}
local mt = {__index=Dependency}

local function get_keys(self, master_key)
    local n = self.cache:get(master_key)
    if not n then
        return nil
    end
    local keys = {}
    for i=1, n do
        keys[i] = master_key .. tostring(i)
    end
    local keys2 = self.cache:get_multi(keys)
    for i=1, #keys do
        local key = keys2[keys[i]]
        if key then
            keys[#keys+1] = key
        end
    end
    keys[#keys+1] = master_key
    return keys
end

local function next_key(self, master_key)
    local i = self.cache:incr(master_key)
    if not i then
        self.cache:add(master_key, 0)
        i = self.cache:incr(master_key)
    end
    return master_key .. tostring(i)
end

function Dependency:add(master_key, key)
    return self.cache:add(next_key(self, master_key), key, self.time)
end

function Dependency:delete(master_key)
    local keys = get_keys(self, master_key)
    if keys then
        for i=1, #keys do
            self.cache:delete(keys[i])
        end
    end
end

local function new(cache, time)
    return setmetatable({cache=cache, time=time}, mt)
end

return {
    new = new
}
