local mixin = require 'core.mixin'
local base = require 'http.adapters.nginx.base'
local setmetatable, next = setmetatable, next


local ResponseWriter = {__index = mixin(base.ResponseWriter, {
    write = function(self, c)
        local b = self.buffer
        b[#b+1] = c
    end
})}

local Request = {__index = base.Request}

return function(app)
    return function(ngx)
        local var = ngx.var
        local headers = ngx.header
        local w = setmetatable({
            ngx = ngx,
            headers = {},
            buffer = {}
        }, ResponseWriter)
        local req = setmetatable({
            ngx = ngx,
            method = var.request_method,
            path = var.uri
        }, Request)
        app(w, req)
        for name, value in next, w.headers do
            headers[name] = value
        end
        ngx.print(w.buffer)
        ngx.eof()
    end
end
