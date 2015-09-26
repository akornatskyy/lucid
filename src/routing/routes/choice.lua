local format, next = string.format, next
local assert, load, concat, sort = assert, loadstring, table.concat, table.sort
_ENV = nil

local function split(str)
    local r = {}
    local i = 1
    local p = 1
    while true do
        local s = str:find('|', p, true)
        if not s then
            r[i] = str:sub(p)
            break
        end
        r[i] = str:sub(p, s - 1)
        p = s + 1
        i = i + 1
    end
    return r
end

local function tblcopy(t)
    local r = {}
    for k, v in next, t do
        r[k] = v
    end
    return r
end

local function gen_match(matches)
    local r = {}
    for pattern in next, matches do
        r[#pattern] = true
    end
    local s = {}
    for l in next, r do
        s[#s+1] = l
    end
    sort(s)
    r = {'local '}
    for i=#s, 1, -1 do
        local l = s[i]
        r[#r+1] = format([[
            r = m[sub(path, 1, %d)]
            if r then
                return %d, r
            end
        ]], l, l)
    end
    return format([[
        local sub = string.sub
        _ENV = nil
        return function(self, path)
            local m = self.m
            %s
            return nil
        end
    ]], concat(r, '\n'))
end

local function new(pattern, finishing, args)
    local prefix, name, choices, suffix = pattern:match(
        '^([%w/]*){([%w_]+):%(([%w|]+)%)}([%w/]*)$')
    if prefix then
        local a, c, m, self
        args = args or {}
        choices = split(choices)
        m = {}
        for i = 1, #choices do
            c = choices[i]
            a = args and tblcopy(args) or {}
            a[name] = c
            m[prefix .. c .. suffix] = a
        end
        self = {
            exact_matches = m,
            fmt = {prefix, name, suffix}
        }
        --if not finishing then
            self.m = m
            self.match = assert(load(gen_match(m)))()
        --end
        return self
    end
    return nil
end

return {
    new = new
}
