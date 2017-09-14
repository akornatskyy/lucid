local class = require 'core.class'
local mixin = require 'core.mixin'
local web = require 'web'


local BaseHandler = mixin({}, web.mixins.routing)

--[[
    lurl -v demos.web.routing /en/user/123
    curl -v http://127.0.0.1:8080/en/user/123
--]]
local UserHandler = class(BaseHandler, {})
function UserHandler:get()
    assert('user' == self.req.route_args.route_name)
    assert('/de/user/1' == self:path_for('user', {locale='de', user_id='1'}))
    assert('/' .. self.req.route_args.locale .. '/user/2' ==
        self:path_for('user', {user_id='2'}))
    assert(self.req.path == self:path_for('user'))
    self.w:write(self:absolute_url_for('user') .. '\n')
end

local UsersHandler = class(BaseHandler, {
    get = function(self)
        return self.w:write(self:path_for('users'))
    end,
    post = function(self)
        return self.w:write('user added')
    end
})

-- url mapping

local user_urls = {
    {'user/{user_id:i}', UserHandler, name='user'}
}

local all_urls = {
    {'{locale:(en|de)}/', user_urls},
    {'api/users', UsersHandler, name='users'}
}

-- config

local options = {
    --root_path = '/',
    urls = all_urls
}

return web.app({web.middleware.routing}, options)
