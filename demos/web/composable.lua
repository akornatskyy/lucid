local class = require 'core.class'
local web = require 'web'

local WelcomeHandler = class {
    get = function(self)
        self.w:write('hi')
    end
}

-- url mapping

local greetings_urls = {
    {'hi', WelcomeHandler}
}

local all_urls = {
    {'greetings/', greetings_urls}
}

-- config

local options = {
    urls = all_urls
}

--[[
    lurl -v demos/web/composable.lua /greetings/hi
--]]
return web.app({web.middleware.routing}, options)
