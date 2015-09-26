local setmetatable, concat, tostring = setmetatable, table.concat, tostring
local date = os.date
_ENV = nil

local parse = function(c)
    local r = {}
    local s = 1
    while true do
        local i = c:find('=', s, true)
        if not i then
            r[''] = c:sub(s)
            break
        end
        i = i + 1
        local e = c:find('; ', i, true)
        if not e then
            r[c:sub(s, i - 2)] = c:sub(i)
            break
        end
        r[c:sub(s, i - 2)] = c:sub(i, e - 1)
        s = e + 2
    end
    return r
end

local dump = function(self)
    local r = {self.name, '=', self.value}
    if self.path then
        r[4] = '; Path='
        r[5] = self.path
    end
    if self.domain then
        r[#r+1] = '; Domain='
        r[#r+1] = self.domain
    end
    if self.expires then
        r[#r+1] = '; Expires='
        -- RFC1123
        r[#r+1] = date('!%a, %d %b %Y %H:%M:%S GMT', self.expires)
    end
    if self.max_age then
        r[#r+1] = '; Max-Age='
        r[#r+1] = tostring(self.max_age)
    end
    if self.http_only then
        r[#r+1] = '; HttpOnly'
    end
    if self.secure then
        r[#r+1] = '; Secure'
    end
    return concat(r)
end

local delete = function(self)
    local r = {self.name, '=; Expires=Thu, 01 Jan 1970 00:00:00 GMT'}
    if self.path then
        r[3] = '; Path='
        r[4] = self.path
    end
    if self.domain then
        r[#r+1] = '; Domain='
        r[#r+1] = self.domain
    end
    return concat(r)
end

local Cookie = {
    __index = {
        dump = dump
    },
    __tostring = dump
}

local new = function(c)
    return setmetatable(c, Cookie)
end

return {
    new = new,
    parse = parse,
    dump = dump,
    delete = delete
}
