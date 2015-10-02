local mixin = require 'core.mixin'
local http = require 'http'


mixin(http.Request, http.mixins.routing)

local app = http.app.new()
app:use(http.middleware.routing)

--[[
    lurl -v demos.http.redirect /
    curl -v http://127.0.0.1:8080
--]]
app:get('', function(w, req)
    return w:redirect(req:absolute_url_for('welcome'))
end)

app:get('welcome', 'welcome', function(w, req)
    return w:write('Hello World!\n')
end)

return app()
