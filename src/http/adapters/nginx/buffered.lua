local mixin = require 'core.mixin'
local base = require 'http.adapters.nginx.base'
local setmetatable, tostring, next = setmetatable, tostring, next


local ResponseWriter = {__index = mixin(base.ResponseWriter, {
    write = function(self, c)
        local b = self.b
        b[#b+1] = c
        self.s = self.s + c:len()
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
            b = {},
            s = 0
        }, ResponseWriter)
        local req = setmetatable({
            ngx = ngx,
            method = var.request_method,
            path = var.uri
        }, Request)
        app(w, req)
        headers['Content-Length'] = tostring(w.s)
        for name, value in next, w.headers do
            headers[name] = value
        end
        ngx.print(w.b)
        ngx.eof()
    end
end
