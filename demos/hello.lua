local class = require 'core.class'
local web = require 'web'


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

local app = web.app({web.middleware.routing}, options)
if not debug.getinfo(3) then
    local clockit = require 'core.clockit'
    local request = require 'http.functional.request'
    local writer = require 'http.functional.response'
    local w = writer.new()
    local req = request.new()
    clockit.ptimes(function()
        app(w, req)
    end)
end
return app
