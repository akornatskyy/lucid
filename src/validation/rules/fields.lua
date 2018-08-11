local next = next

local check_fields = {
    __index = {
        msg = 'Unknown field name [%s].',
        validate = function(self, value, model, translations)
            for name in next, model do
                if not self.allowed[name] then
                    return translations:gettext(self.msg):format(name:sub(1, 9))
                end
            end
            return nil
        end
    }
}

return function(t)
    assert(type(t) == 'table')
    local allowed = {}
    local msg
    if t.allowed then
        msg = t.msg
        t = t.allowed
    end
    for i = 1, #t do
        allowed[t[i]] = true
    end
    return setmetatable({allowed = allowed, msg = msg}, check_fields)
end
