local type = type

return {
    -- assumes: self.headers

    get_status_code = function(self)
    end,

    set_status_code = function(self, code)
    end,

    write = function(self, c)
    end,

    flush = function(self)
    end,

    add_header = function(self, name, value)
        local h = self.headers
        local t = h[name]
        if t then
            if type(t) == 'string' then
                h[name] = {t, value}
            else
                t[#t+1] = value
            end
        else
            h[name] = value
        end
    end,

    set_cookie = function(self, s)
        return self:add_header('Set-Cookie', s)
    end,

    redirect = function(self, absolute_url, status_code)
        self:set_status_code(status_code or 302)
        self.headers['Location'] = absolute_url
    end
}
