local validate = function(self, value, model, translations)
    if not value or value == '' or value == 0 then
        return translations:gettext(self.msg)
    end
    return nil
end

local required = {
    msg = 'Required field cannot be left blank.',
    validate = validate
}

return function(o)
    if o and o.msg then
        o.validate = validate
        return o
    end
    return required
end
