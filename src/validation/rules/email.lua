local find = string.find


local validate = function(self, value, model, translations)
    if value and not find(
            value,
            '^[A-Za-z0-9%.%%%+%-%_]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?') then
        return translations:gettext(self.msg)
    end
    return nil
end

local email = {
    msg = 'Required to be a valid email address.',
    validate = validate
}

return function(o)
    if o and o.msg then
        o.validate = validate
        return o
    end
    return email
end
