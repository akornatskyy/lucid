local mixin = require 'core.mixin'
local base = require 'http.adapters.nginx.base'
local setmetatable = setmetatable


local ResponseWriter = {__index = mixin(base.ResponseWriter, {
    write = function(self, c)
        return self.ngx.print(c)
    end
})}

local Request = {__index = base.Request}

return function(app)
    return function(ngx)
        local var = ngx.var
        local w = setmetatable({
            ngx = ngx,
            headers = ngx.header
        }, ResponseWriter)
        local req = setmetatable({
            ngx = ngx,
            method = var.request_method,
            path = var.uri
        }, Request)
        app(w, req)
        ngx.eof()
    end
end
