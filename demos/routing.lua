local class = require 'core.class'
local mixin = require 'core.mixin'
local web = require 'web'
_ENV = nil


local BaseHandler = mixin({}, web.mixins.RoutingMixin)

--[[
    luajit lurl.lua -v demos.routing /en/user/123
    curl -v http://127.0.0.1:8080/en/user/123
--]]
local UserHandler = class(BaseHandler, {})
function UserHandler:get()
    assert('/de/user/1' == self:path_for('user', {locale='de', user_id='1'}))
    assert('/en/user/2' == self:path_for('user', {user_id='2'}))
    assert(self.req.path == self:path_for('user'))
    self.w:write(self:absolute_url_for('user') .. '\n')
end

-- url mapping

local user_urls = {
    {'user/{user_id:i}', UserHandler, name='user'}
}

local all_urls = {
    {'{locale:(en|de)}/', user_urls}
}

-- config

local options = {
    --root_path = '/',
    urls = all_urls
}

return web.app({web.middleware.routing}, options)
