local class = require 'core.class'
local http = require 'http'
local web = require 'web'

-- handlers

local function welcome(w)
    w:write('Hello World!\n')
end

local WelcomeHandler = class({
    get = function(self)
        self.w:write('Hello World!\n')
    end
})

-- url mapping

local all_urls = {
    {'', welcome},
    {'welcome', WelcomeHandler}
}

-- config

local options = {
    urls = all_urls
}

return http.app({web.middleware.routing}, options)
