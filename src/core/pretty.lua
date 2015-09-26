local next, type, tostring = next, type, tostring
local sort, concat = table.sort, table.concat
_ENV = nil

local spaces = {
    default = {bracket='', indent='', item=', ', key=' = '},
    compact = {bracket='', indent='', item=', ', key='='},
    indented = {bracket='\n', indent='    ', item=',\n', key=' = '},
    min = {bracket='', indent='', item=',', key='='},
}
local dump_value

local function dump_table(t, space, level)
    local b = {}
    local ikeys = {}
    local skeys = {}
    local t2 = {}
    local indent = space.indent:rep(level)
    for k in next, t do
        if type(k) == 'number' then
            ikeys[#ikeys+1] = k
        else
            local k1 = tostring(k)
            skeys[#skeys+1] = k1
            t2[k1] = k
        end
    end
    sort(ikeys)
    sort(skeys)
    for i=1, #ikeys do
        b[#b+1] = dump_value(t[ikeys[i]], space, level)
    end
    for i=1, #skeys do
        local k = t2[skeys[i]]
        b[#b+1] = '[' .. dump_value(k, space, level) .. ']' ..
                  space.key .. dump_value(t[k], space, level)
    end
    if #b == 0 then
        return '{}'
    end
    return '{' .. space.bracket ..
           indent .. concat(b, space.item .. indent) .. space.bracket ..
           space.indent:rep(level - 1) .. '}'
end

function dump_value(obj, space, level)
    local t = type(obj)
    if t == 'string' then
        return ('%q'):format(obj)
    elseif t == 'number' or t == 'boolean' or t == 'nil' then
        return tostring(obj)
    elseif t == 'table' then
        return dump_table(obj, space, level + 1)
    end
    return '"<' .. t ..'>"'
end

local function dump(obj, space)
    return dump_value(obj, space or spaces.default, 0)
end

return {
    dump = dump,
    spaces = spaces
}
