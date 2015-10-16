local mixin = require 'core.mixin'
local http = require 'http'


mixin(http.Request, http.mixins.routing)

local app = http.app.new()
app:use(http.middleware.routing)

--[[
    lurl -v demos.http.routing /en/user/123
    curl -v http://127.0.0.1:8080/en/user/123
--]]
app:get('{locale}/user/{user_id:i}', 'user', function(w, req)
    assert('user' == req.route_args.route_name)
    assert('/de/user/1' == req:path_for('user', {locale='de', user_id='1'}))
    assert('/en/user/2' == req:path_for('user', {user_id='2'}))
    assert(req.path == req:path_for('user'))
    w:write(req:absolute_url_for('user') .. '\n')
end)

return app()
