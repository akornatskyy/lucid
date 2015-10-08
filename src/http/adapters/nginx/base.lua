local mixin = require 'core.mixin'
local Request = require 'http.request'
local ResponseWriter = require 'http.response'
local json_decode

do
    local json = require 'core.encoding.json'
    json_decode = json.decode
end

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

    parse_body = function(self)
        local body
        local r = self.ngx.req
        r.read_body()
        local headers = r.get_headers()
        local t = headers['content-type']
        if t and t:find('application/json', 1, true) then
            body = r.get_body_data()
            local c = body:sub(1, 1)
            if c ~= '{' and c ~= '[' then
                return nil
            end
            body = json_decode(body)
        else
            body = r.get_post_args()
        end
        self.body = body
        return body
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
