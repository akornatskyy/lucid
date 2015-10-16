local Mixin = {}

function Mixin:get_locale()
    return self.req.route_args.locale or ''
end

return Mixin
