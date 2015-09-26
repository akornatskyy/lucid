_ENV = nil

local function wrap_middleware(following, func)
    return function(w, req)
        return func(w, req, following)
    end
end

return function(middlewares, options)
    local r, m
    for i = #middlewares, 1, -1 do
        m = middlewares[i](options)
        if m then
            r = wrap_middleware(r, m)
        end
    end
    return r
end
