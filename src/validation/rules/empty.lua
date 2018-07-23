local validate = function(self, value, model, translations)
    if value ~= '' then
        return translations:gettext(self.msg)
    end
    return nil
end

local empty = {
    msg = 'Required to be left blank.',
    validate = validate
}

return function(o)
    if o and o.msg then
        o.validate = validate
        return o
    end
    return empty
end
