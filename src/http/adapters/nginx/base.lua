local mixin = require 'core.mixin'
local Request = require 'http.request'
local ResponseWriter = require 'http.response'
_ENV = nil


mixin(ResponseWriter, {
    get_status_code = function(self)
        return self.ngx.status
    end,

    set_status_code = function(self, code)
        self.ngx.status = code
    end,

    flush = function(self)
        self.ngx.flush()
    end
})

mixin(Request, {
    parse_query = function(self)
        local query = self.ngx.req.get_uri_args()
        self.query = query
        return query
    end,

    parse_headers = function(self)
        local headers = self.ngx.req.get_headers()
        self.headers = headers
        return headers
    end,

    parse_form = function(self)
        -- TODO: ajax
        local r = self.ngx.req
        r.read_body()
        local form = r.get_post_args()
        self.form = form
        return form
    end,

    server_parts = function(self)
        local var = self.ngx.var
        return var.scheme, var.host, var.server_port
    end
})

return {
    ResponseWriter = ResponseWriter,
    Request = Request
}
