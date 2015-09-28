local class = require 'core.class'
local web = require 'web'

--[[
    luajit lurl.lua -v demos.hello /
    curl -v http://localhost:8080
--]]
local WelcomeHandler = class({
    get = function(self)
        self.w:write('Hello World!\n')
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
