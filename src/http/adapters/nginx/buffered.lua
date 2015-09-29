local mixin = require 'core.mixin'
local base = require 'http.adapters.nginx.base'
local setmetatable, tostring = setmetatable, tostring


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
        local b = {}
        local w = setmetatable({
            ngx = ngx,
            headers = ngx.header,
            b = b,
            s = 0
        }, ResponseWriter)
        local req = setmetatable({
            ngx = ngx,
            method = var.request_method,
            path = var.uri
        }, Request)
        app(w, req)
        ngx.header['Content-Length'] = tostring(w.s)
        ngx.print(b)
        ngx.eof()
    end
end
