local dump
do
    local cookie = require 'http.cookie'
    dump = cookie.dump
end

local Mixin = {}

function Mixin:parse_auth_cookie()
    local req = self.req
    local o = req.options
    local c = req:get_cookie(o.auth_cookie.name)
    if not c then
        return nil
    end
    local ticket = o.ticket
    local p, time_left = ticket:decode(c)
    if p then
        if time_left < ticket.max_age / 2 then
            self:set_auth_cookie(p)
        end
    else
        self:set_auth_cookie()
    end
    return p, time_left
end

function Mixin:set_auth_cookie(s)
    local o = self.req.options
    local c = o.auth_cookie
    if s then
        c = dump {
            name=c.name,
            value=o.ticket:encode(s),
            path=c.path,
            domain=c.domain,
            secure=c.secure,
            http_only=true
        }
    else
        c = c.deleted
    end
    self.w:add_header('Set-Cookie', c)
end

return Mixin
