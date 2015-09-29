local Mixin = {}


function Mixin:path_for(name, args)
    if args then
        return self.options.router:path_for(name, args, self.route_args)
    else
        return self.options.router:path_for(name, self.route_args)
    end
end

function Mixin:absolute_url_for(name, args)
    local scheme, host, port = self:server_parts()
    return scheme .. '://' .. host ..
           (port == '80' and '' or ':' .. port) ..
           self:path_for(name, args)
end

return Mixin
