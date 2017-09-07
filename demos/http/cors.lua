local http = require 'http'

local app = http.app.new {
    cors = http.cors.new {
        allow_credentials = true,
        allowed_origins = {'*'},
        allowed_methods = {'GET', 'HEAD', 'POST', 'PUT', 'DELETE'},
        allowed_headers = {'content-type', 'x-requested-with'},
        exposed_headers = {'content-length', 'etag'},
        max_age = 180
    }
}
app:use(http.middleware.cors)
app:use(http.middleware.routing)

--[[
    lurl -v demos.http.cors /
    curl -v http://127.0.0.1:8080
--]]
app:all('', function(w, req)
    return w:write('Hello World!\n')
end)

return app()
