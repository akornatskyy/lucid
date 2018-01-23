local cookie = require 'http.cookie'
local parse_cookie = cookie.parse


return {
    -- assumes: self.method, self.path

    parse_query = function(self)
        return self.query
    end,

    parse_headers = function(self)
        return self.headers
    end,

    parse_body = function(self)
        return self.body
    end,

    parse_cookie = function(self)
        local headers = self.headers or self:parse_headers()
        local c = headers['cookie']
        if not c then
            local cookies = {}
            self.cookies = cookies
            return cookies
        end
        local cookies = parse_cookie(c)
        self.cookies = cookies
        return cookies
    end,

    is_ajax = function(self)
        local headers = self.headers or self:parse_headers()
        return headers['x-requested-with'] == 'XMLHttpRequest'
    end,

    server_parts = function(self)
    end
}
