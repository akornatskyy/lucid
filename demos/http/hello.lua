local http = require 'http'

local app = http.app.new()
app:use(http.middleware.routing)

--[[
    lurl -v demos.http.hello /
    curl -v http://127.0.0.1:8080
--]]
app:get('', function(w, req)
    return w:write('Hello World!\n')
end)

return app()
