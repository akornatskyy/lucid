local class = require 'core.class'
local request_key = require 'http.request_key'
local web = require 'web'


local cache_profile = {
    key = request_key.new '$m:$p',
    time = 600
}

local c1 = 0
local c2 = 0

local CounterHandler = class {
    get = function(self)
        c1 = c1 + 1
        self.w:write('Counter = ' .. c1 .. '\n')
        self.w.cache_profile = cache_profile
    end
}

local NotFoundCounterHandler = class {
    post = function(self)
        c2 = c2 + 1
        self.w:set_status_code(404)
        self.w:write('Counter = ' .. c2 .. '\n')
        self.w.cache_profile = cache_profile
    end
}

-- url mapping

local all_urls = {
    {'', CounterHandler},
    {'not-found', NotFoundCounterHandler}
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
