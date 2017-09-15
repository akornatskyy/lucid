local class = require 'core.class'
local opt = require 'http.middleware.opt'
local web = require 'web'

local WelcomeHandler = class {
    get = function(self)
        self.w:write(self.req.options.option1)
    end
}

local function my_middleware(following, options)
    local option1 = options.option1
    return function(w, req)
        w:write(option1)
        return following(w, req)
    end
end

local middlewares = {
    opt(my_middleware, {
        option1 = 'B' -- this will override default in options
    }),
    web.middleware.routing
}

local options = {
    option1 = 'A',
    urls = {
        {'', WelcomeHandler}
    }
}

return web.app(middlewares, options)
