local assert, setmetatable, find = assert, setmetatable, string.find


local check_found = {__index = {
    msg = 'Required to match validation pattern.',
    validate = function(self, value, model, translations)
        if value and not find(value, self.pattern, 1, self.plain) then
            return translations:gettext(self.msg)
        end
        return nil
    end
}}

local check_not_found = {__index = {
    msg = 'Required to not match validation pattern.',
    validate = function(self, value, model, translations)
        if value and find(value, self.pattern, 1, self.plain) then
            return translations:gettext(self.msg)
        end
        return nil
    end
}}

return function(o)
    if o[1] then
        o.pattern = o[1]
        o[1] = nil
    end
    assert(o.pattern, 'bad argument \'pattern\' (string expected)')
    if o.negated then
        return setmetatable(o, check_not_found)
    else
        return setmetatable(o, check_found)
    end
end
