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

local c1 = 0
local c2 = 0

app:get('', function(w)
    c1 = c1 + 1
    w.cache_profile = cache_profile
    return w:write('Counter = ' .. c1 .. '\n')
end)

app:post('not-found', function(w)
    c2 = c2 + 1
    w:set_status_code(404)
    w.cache_profile = cache_profile
    return w:write('Counter = ' .. c2 .. '\n')
end)

return app()
