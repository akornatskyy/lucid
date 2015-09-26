local cookie = require 'http.cookie'
local parse_cookie = cookie.parse
_ENV = nil

return {
    -- assumes: self.method, self.path

    parse_query = function(self)
    end,

    parse_headers = function(self)
    end,

    parse_form = function(self)
    end,

    server_parts = function(self)
    end,

    parse_cookie = function(self)
        local headers = self.headers or self:parse_headers()
        if not headers then
            return nil
        end
        local c = headers['cookie']
        if not c then
            return nil
        end
        local cookies = parse_cookie(c)
        self.cookies = cookies
        return cookies
    end,

    get_cookie = function(self, name)
        local c = self.cookies or self:parse_cookie()
        if not c then
            return nil
        end
        return c[name]
    end,

    is_ajax = function(self)
        local headers = self.headers or self:parse_headers()
        return headers['x-requested-with'] == 'XMLHttpRequest'
    end
}

