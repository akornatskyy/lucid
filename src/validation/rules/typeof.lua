local assert, type, setmetatable = assert, type, setmetatable


local check_generic_type = {__index = {
    msg = 'Required to match %s type.',
    validate = function(self, value, model, translations)
        if type(value) ~= self.type then
            return translations:gettext(self.msg):format(self.type)
        end
        return nil
    end
}}

local check_integer_type = {__index = {
    msg = 'Required to match integer type.',
    validate = function(self, value, model, translations)
        if type(value) ~= 'number' or value % 1 ~= 0 then
            return translations:gettext(self.msg)
        end
        return nil
    end
}}

return function(o)
    if type(o) == 'string' then
        o = {type = o}
    elseif o[1] then
        o.type = o[1]
        o[1] = nil
    end
    assert(o.type, 'bad argument \'type\' (string expected)')
    if o.type == 'integer' then
        return setmetatable(o, check_integer_type)
    end
    return setmetatable(o, check_generic_type)
end
