local validate = function(self, value, model, translations)
    if value ~= nil then
        return translations:gettext(self.msg)
    end
    return nil
end

local nilable = {
    msg = 'Must be left to nil.',
    validate = validate
}

return function(o)
    if o and o.msg then
        o.validate = validate
        return o
    end
    return nilable
end
