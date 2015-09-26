local mixin = require 'core.mixin'
local http = require 'http'
local web = require 'web'
_ENV = nil


local BaseHandler = mixin({}, web.mixins.RoutingMixin)

local RedirectHandler = mixin({}, BaseHandler)

--[[
    curl -v http://127.0.0.1:8080
    curl -v --header "X-Requested-With: XMLHttpRequest"
        http://127.0.0.1:8080
--]]
function RedirectHandler:get()
    return self:redirect_for('welcome')
end

local function welcome(w)
    w:write('Hello World!\n')
end

-- url mapping

local all_urls = {
    {'', {__index=RedirectHandler}},
    {'welcome', welcome, name='welcome'}
}

-- config

local options = {
    urls = all_urls
}

return http.app({web.middleware.routing}, options)
