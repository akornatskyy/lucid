local assert, format, load = assert, string.format, loadstring
local concat = table.concat


local function var_method()
    return nil, 'req.method'
end

local function var_path()
    return nil, 'req.path'
end

local function var_query(name)
    return 'local q = req.query or req:parse_query()',
           '(q["' .. name .. '"] or "")'
end

local function var_headers(name)
    name = name:gsub('_', '-')
    return 'local h = req.headers or req:parse_headers()',
           '(h["' .. name .. '"] or "")'
end

local function var_gzip()
    return 'local h = req.headers',
        '((h["accept-encoding"] or ""):find("gzip", 1, true) and "z" or "")'
end

local variables = {
    method = var_method,
    m = var_method,
    path = var_path,
    p = var_path,
    query = var_query,
    q = var_query,
    headers = var_headers,
    header = var_headers,
    h = var_headers,
    gzip = var_gzip,
    gz = var_gzip
}

local function keys(t)
    local r = {}
    for k in pairs(t) do
        r[#r+1] = k
    end
    return r
end

local function parse_parts(s)
    local parts = {}
    local b = 1
    local e
    local pe = 1
    while true do
        b, e = s:find('%$%w+', b)
        if not b then
            parts[#parts+1] = s:sub(pe)
            break
        end
        parts[#parts+1] = s:sub(pe, b - 1)
        local name = s:sub(b + 1, e)
        e = e + 1
        b, pe = s:find('^_[%w_]+', e)
        if b then
            parts[#parts+1] = {name, s:sub(b + 1, pe)}
            pe = pe + 1
        else
            parts[#parts+1] = {name}
            pe = e
        end
        b = e
    end
    return parts
end

local function build(parts)
    local locals = {}
    local chunks = {}
    for i = 1, #parts do
        if i % 2 == 1 then
            local s = parts[i]
            if #s > 0 then
                chunks[#chunks+1] = format('%q', s)
            end
        else
            local name, param = unpack(parts[i])
            local v = variables[name]
            if not v then
                return error('unknown variable "' .. name .. '"')
            end
            local l, c = v(param)
            if l and #l > 0 then
                locals[l] = true
            end
            chunks[#chunks+1] = c
        end
    end
    locals = concat(keys(locals), '\n        ')
    chunks = concat(chunks, ' ..\n            ')
    return format([[

    return function(req)
        %s
        return %s
    end]], locals, chunks)
end

local function new(s)
    if type(s) ~= 'string' or #s == 0 then
        return error('bad argument #1 to \'new\' (non empty string expected)')
    end
    local source = build(parse_parts(s))
    -- print(source)
    return assert(load(source))()
end

return {
    new = new,
    variables = variables
}
