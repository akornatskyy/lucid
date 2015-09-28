_ENV = nil

--[[
    function middleware(options, following)
        return function(w, req)
            following(w, req)
        end
    end
--]]
return function(middlewares, options)
    local following
    for i = #middlewares, 1, -1 do
        following = middlewares[i](options, following)
    end
    return following
end
