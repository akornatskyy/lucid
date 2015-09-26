local assert, load, next = assert, loadstring, next
local format, concat = string.format, table.concat
_ENV = nil

local function parse(p)
    local fs, ne
    local fmt = {}
    local parts = {}
    local names = {}
    fs = 1
    while true do
        local s, e = p:find('%b()', fs)
        if not s then
            s = p:sub(fs)
            fmt[#fmt+1] = s
            parts[#parts+1] = s
            break
        end
        fmt[#fmt+1] = p:sub(fs, s - 1)
        s, ne = p:find('^%(%?P%b<>', s)
        if s then
            parts[#parts+1] = p:sub(fs, s)
            s = p:sub(s + 4, ne - 1)
            names[#names+1] = s
            fmt[#fmt+1] = s
            parts[#parts+1] = p:sub(ne + 1, e)
        else
            s = #names + 1
            names[s] = s
        end
        fs = e + 1
    end
    return concat(parts, ''), fmt, names
end

local function gen_match(pattern, names, args)
    local n
    local t = {}
    local e = {}
    for k, v in next, args do
        e[k] = v
    end
    if #names == 0 then
        n = ''
    else
        n = {}
        for i = 1, #names do
            local k = names[i]
            n[i] = 'm' .. i
            t[i] = format('[%q] = m%s', k, i)
            e[k] = nil
        end
        n = ', ' .. concat(n, ', ')
    end
    for k, v in next, e do
        t[#t+1] = format('[%q] = %q', k, v)
    end
    return format([[
        local find = string.find
        _ENV = nil
        return function(self, path)
            local s, e%s = find(path, %q)
            if s then
                return e, { %s }
            end
            return nil
        end
    ]], n, pattern, concat(t, ', '))
end

local function new(pattern, finishing, args)
    local fmt, names
    args = args or {}
    pattern, fmt, names = parse(pattern:match('^%^*(.-)%$*$'))
    pattern = '^' .. pattern
    if finishing then
        pattern = pattern .. '$'
    end
    return {
        match = assert(load(gen_match(pattern, names, args)))(),
        fmt = fmt
    }
end

return {
    new = new
}
