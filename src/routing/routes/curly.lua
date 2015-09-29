local base = require('routing.routes.pattern').new
local format, concat = string.format, table.concat


local patterns = {
    -- one or more digits
    ['i'] = '%d+',
    ['int'] = '%d+',
    ['number'] = '%d+',
    ['digits'] = '%d+',
    -- one or more word characters
    ['w'] = '%w+',
    ['word'] = '%w+',
    -- everything until `/`
    ['s'] = '[^/]+',
    ['segment'] = '[^/]+',
    ['part'] = '[^/]+',
    -- any
    ['*'] = '.+',
    ['a'] = '.+',
    ['any'] = '.+',
    ['rest'] = '.+'
}


local function convert(pattern)
    local fs, s, e, g, p
    local parts = {}
    fs = 1
    while true do
        s, e, g, p = pattern:find('{([%w_]+):?(.-)}', fs)
        if not s then
            if fs == 1 then
                return nil
            end
            parts[#parts+1] = pattern:sub(fs)
            break
        end
        parts[#parts+1] = pattern:sub(fs, s - 1)
        if p == '' then
            p = patterns['s']
        else
            p = patterns[p] or p
        end
        parts[#parts+1] = format('(?P<%s>%s)', g, p)
        fs = e + 1
    end
    return concat(parts, '')
end

local function new(pattern, finishing, args)
    pattern = convert(pattern)
    if pattern then
        return base(pattern, finishing, args)
    end
    return nil
end

return {
    patterns = patterns,
    convert = convert,
    new = new
}
