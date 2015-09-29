local Mixin = {}

function Mixin:path_for(name, args)
    local req = self.req
    if args then
        return req.options.router:path_for(name, args, req.route_args)
    else
        return req.options.router:path_for(name, req.route_args)
    end
end

function Mixin:absolute_url_for(name, args)
    local scheme, host, port = self.req:server_parts()
    return scheme .. '://' .. host ..
           (port == '80' and '' or ':' .. port) ..
           self:path_for(name, args)
end

function Mixin:redirect_for(name, args)
    return self.w:redirect(self:absolute_url_for(name, args),
                           self.req:is_ajax() and 207 or 302)
end

function Mixin:see_other_for(name, args)
    return self.w:redirect(self:absolute_url_for(name, args),
                           self.req:is_ajax() and 207 or 303)
end

return Mixin
