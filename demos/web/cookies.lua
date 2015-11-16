local class = require 'core.class'
local cookie = require 'http.cookie'
local web = require 'web'

local WelcomeHandler = class({
    get = function(self)
        self.w:set_cookie(cookie.dump {
            name = 'm', value = 'hello', path = '/'
        })
        self.w:set_cookie(cookie.dump {
            name = 'c', value = '100', http_only = true
        })
    end
})

local RemoveHandler = class({
    get = function(self)
        self.w:set_cookie(cookie.delete {name = 'c'})
    end
})

-- url mapping

local all_urls = {
    {'', WelcomeHandler},
    {'remove', RemoveHandler}
}

-- config

local options = {
    urls = all_urls
}

return web.app({web.middleware.routing}, options)
