local setmetatable = setmetatable

return function(middleware, options)
    assert(middleware, 'middleware')
    assert(options, 'options')
    return function(following, app_options)
        return middleware(following, setmetatable({}, {__index=function(t, k)
            return options[k] or app_options[k]
        end}))
    end
end
