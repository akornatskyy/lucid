local concat = table.concat


local parse = function(s)
    local t = {}
    local r = 1
    local i = 1
    while r <= 4 do
        local j = s:find('\15', i, true)
        if not j then
            t[r] = s:sub(i)
            break
        end
        t[r] = s:sub(i, j - 1)
        r = r + 1
        i = j + 1
    end
    if r ~= 4 then
        return nil
    end
    s = t[2]
    r = {}
    i = 1
    while true do
        local j = s:find(';', i, true)
        if not j then
            if i ~= 1 then
                r[s:sub(i)] = true
            elseif #s > 0 then
                r[s] = true
            end
            break
        end
        r[s:sub(i, j - 1)] = true
        i = j + 1
    end
    return {
        id = t[1],
        roles = r,
        alias = t[3],
        extra = t[4]
    }
end

local dump = function(self)
    local roles = ''
    if self.roles then
        roles = {}
        for r in next, self.roles do
            roles[#roles+1] = r
        end
        roles = concat(roles, ';')
    end
    return concat({
        self.id,
        roles,
        self.alias or '',
        self.extra or ''
    }, '\15')
end

return {
    parse = parse,
    dump = dump
}
