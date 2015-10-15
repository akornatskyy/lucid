local http = require 'http'

local greetings = http.app.new()

greetings:get('hi', function(w)
    return w:write('hi')
end)


local app = http.app.new()
app:add('greetings/', greetings)
app:use(http.middleware.routing)

--[[
    lurl -v demos/http/composable.lua /greetings/hi
--]]
return app()
