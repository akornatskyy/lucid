local class = require 'core.class'
local mixin = require 'core.mixin'
local web = require 'web'

local BaseHandler = {}

mixin(BaseHandler, web.mixins.json)

--[[
    lurl -v demos.web.json /
    curl -v http://localhost:8080
--]]
local WelcomeHandler = class(BaseHandler, {
    get = function(self)
        self:json {message = 'Hello World!'}
    end
})

-- url mapping

local all_urls = {
    {'', WelcomeHandler}
}

-- config

local options = {
    urls = all_urls
}

return web.app({web.middleware.routing}, options)
