local class = require 'core.class'
local mixin = require 'core.mixin'
local web = require 'web'


local BaseHandler = mixin({}, web.mixins.RoutingMixin)

--[[
    lurl -v demos.web.redirect /
    lurl -v -H "X-Requested-With: XMLHttpRequest" demos.redirect /
    curl -v http://127.0.0.1:8080
    curl -v -H "X-Requested-With: XMLHttpRequest" http://127.0.0.1:8080
--]]
local RedirectHandler = class(BaseHandler, {})
function RedirectHandler:get()
    return self:redirect_for('welcome')
end

local WelcomeHandler = class(BaseHandler, {
    get = function(self)
        self.w:write('Hello World!\n')
    end
})

-- url mapping

local all_urls = {
    {'', RedirectHandler},
    {'welcome', WelcomeHandler, name='welcome'}
}

-- config

local options = {
    urls = all_urls
}

return web.app({web.middleware.routing}, options)
