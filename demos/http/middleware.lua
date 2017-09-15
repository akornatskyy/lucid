local http = require 'http'
local opt = require 'http.middleware.opt'

local app = http.app.new {
    option1 = 'A'
}

local function my_middleware(following, options)
    local option1 = options.option1
    return function(w, req)
        w:write(option1)
        return following(w, req)
    end
end

app:use(opt(my_middleware, {
    option1 = 'B' -- this will override default in app.options
}))

app:use(http.middleware.routing)
app:get('', function(w, req)
    w:write(req.options.option1)
end)

return app()
