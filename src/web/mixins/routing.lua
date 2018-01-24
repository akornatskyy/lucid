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
    local req = self.req
    local headers = req.headers or req:parse_headers()
    local is_ajax = headers['x-requested-with'] == 'XMLHttpRequest'
    return self.w:redirect(self:absolute_url_for(name, args),
                           is_ajax and 207 or 302)
end

return Mixin
