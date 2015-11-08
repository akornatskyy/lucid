local request_key = require 'http.request_key'
local http = require 'http'


local Cache = {__index={
    get = function(self, key)
        return self.items[key]
    end,

    set = function(self, key, value, time)
        self.items[key] = value
    end
}}

local app = http.app.new {
    cache = setmetatable({items = {}}, Cache),
}
app:use(http.middleware.caching)
app:use(http.middleware.routing)

local cache_profile = {
    key = request_key.new '$m:$p',
    time = 600
}

local counter = 0

app:get('', function(w)
    counter = counter + 1
    w.cache_profile = cache_profile
    return w:write('Counter = ' .. counter .. '\n')
end)

return app()
