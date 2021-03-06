local mixin = require 'core.mixin'
local http = require 'http'


mixin(http.Request, http.mixins.routing)

local module = http.app.new()

--[[
    lurl -v demos.http.routing /en/user/123
    curl -v http://127.0.0.1:8080/en/user/123
--]]
module:get('user/{user_id:i}', 'user', function(w, req)
    assert('user' == req.route_args.route_name)
    assert('/de/user/1' == req:path_for('user', {locale='de', user_id='1'}))
    assert('/' .. req.route_args.locale .. '/user/2' ==
        req:path_for('user', {user_id='2'}))
    assert(req.path == req:path_for('user'))
    w:write(req:absolute_url_for('user') .. '\n')
end)

local app = http.app.new()
app:add('{locale:(en|de)}/', module)
app:use(http.middleware.routing)

app:all('all', function(w, req)
    return w:write('all')
end)

app:route('api/users', 'users')
:get(function(w, req)
    return w:write(req:path_for('users'))
end)
:post(function(w, req)
    return w:write('user added')
end)

return app()
