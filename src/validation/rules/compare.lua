local succeed = require 'validation.rules.succeed'
local setmetatable = setmetatable


local check_equal = {__index = {
    msg = 'The value failed equality comparison with "%s".',
    validate = function(self, value, model, translations)
        if value ~= model[self.equal] then
            return translations:gettext(self.msg):format(self.equal)
        end
        return nil
    end
}}

local check_not_equal = {__index = {
    msg = 'The value failed not equal comparison with "%s".',
    validate = function(self, value, model, translations)
        if value == model[self.not_equal] then
            return translations:gettext(self.msg):format(self.not_equal)
        end
        return nil
    end
}}

return function(o)
    if o.equal then
        return setmetatable(o, check_equal)
    elseif o.not_equal then
        return setmetatable(o, check_not_equal)
    else
        return setmetatable(o, succeed)
    end
end
