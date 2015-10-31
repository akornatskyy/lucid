local mixin = require 'core.mixin'
local Request = require 'http.request'
local setmetatable = setmetatable
local mt = {__index = Request}


local headers = {
    ['host'] = 'localhost:8080',
    ['user-agent'] = 'lurl/scm-0',
    ['accept'] = '*/*'
}

local defaults = {
    method = 'GET',
    path = '/',
    body = {}
}

mixin(Request, {
    server_parts = function()
        return 'http', 'localhost', '8080'
    end
})

local function new(self)
    self = mixin({}, defaults, self or {})
    if self.headers then
        self.headers = mixin({}, headers, self.headers)
    else
        self.headers = headers
    end
    return setmetatable(self, mt)
end

return {
    new = new,
    defaults = defaults,
    headers = headers
}
