local http = require 'http'

local greetings = http.app.new()

greetings.mounted = false
greetings:on('mounted', function(parent)
    assert(parent)
    greetings.mounted = true
end)

greetings:get('hi', function(w)
    assert(greetings.mounted, 'mounted not called')
    return w:write('hi')
end)


local app = http.app.new()
app:add('greetings/', greetings)
app:use(http.middleware.routing)

--[[
    lurl -v demos/http/composable.lua /greetings/hi
--]]
return app()
