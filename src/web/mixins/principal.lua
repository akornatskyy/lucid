local Mixin = {}

function Mixin:get_principal()
    local p = self.principal
    if p then
        return p
    end
    p = self:parse_auth_cookie()
    if p then
        p = self.req.options.principal.parse(p)
    else
        p = false
    end
    self.principal = p
    return p
end

function Mixin:set_principal(p)
    self.principal = p
    if p then
        p = self.req.options.principal.dump(p)
    end
    return self:set_auth_cookie(p)
end

return Mixin
