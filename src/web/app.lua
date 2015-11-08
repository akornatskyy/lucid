--[[
    function middleware(following, options)
        return function(w, req)
            following(w, req)
        end
    end
--]]
return function(middlewares, options)
    local following
    for i = #middlewares, 1, -1 do
        following = middlewares[i](following, options)
    end
    return following
end
