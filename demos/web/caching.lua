local class = require 'core.class'
local request_key = require 'http.request_key'
local web = require 'web'


local cache_profile = {
    key = request_key.new '$m:$p',
    time = 600
}

local counter = 0

local CounterHandler = class({
    get = function(self)
        counter = counter + 1
        self.w:write('Counter = ' .. counter .. '\n')
        self.w.cache_profile = cache_profile
    end
})

-- url mapping

local all_urls = {
    {'', CounterHandler}
}

-- config

local Cache = {__index={
    get = function(self, key)
        return self.items[key]
    end,

    set = function(self, key, value, time)
        self.items[key] = value
    end
}}

local options = {
    cache = setmetatable({items = {}}, Cache),
    urls = all_urls
}

return web.app({web.middleware.caching, web.middleware.routing}, options)
