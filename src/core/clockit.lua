local clock = require('socket').gettime


local function clockit(n, f)
    local t = clock()
    for i = 1, n do
        f()
    end
    return clock() - t
end

local function ptimes(...)
    local n = 3
    local k = 100000
    local f
    local args = {...}
    if #args == 1 then
        f = args[1]
    elseif #args == 2 then
        k, f = unpack(args)
    else
        n, k, f = unpack(args)
    end
    for i = 1, n do
        local t = clockit(k, f)
        local units = ''
        t = t and k / t
        if t > 1000000.0 then
            t = t / 1000000.0
            units = 'M'
        elseif t > 1000.0 then
            t = t / 1000.0
            units = 'K'
        end
        print(string.format('#%d => %.2f' .. units, i, t))
    end
end

return {
    clockit = clockit,
    ptimes = ptimes
}
