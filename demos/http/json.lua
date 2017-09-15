local mixin = require 'core.mixin'

local http = require 'http'

mixin(http.ResponseWriter, http.mixins.json)

local app = http.app.new()
app:use(http.middleware.routing)

--[[
    lurl -v demos.http.json /
    curl -v http://127.0.0.1:8080
--]]
app:get('', function(w, req)
    return w:json {message = 'Hello World!'}
end)

return app()
