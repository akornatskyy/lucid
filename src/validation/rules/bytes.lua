local succeed = require 'validation.rules.succeed'

local setmetatable = setmetatable


local check_min = {__index = {
    msg = 'Required to be a minimum of %d bytes in length.',
    validate = function(self, value, model, translations)
        if value and value:len() < self.min then
            return translations:gettext(self.msg):format(self.min)
        end
        return nil
    end
}}

local check_max = {__index = {
    msg = 'Exceeds maximum length of %d.',
    validate = function(self, value, model, translations)
        if value and value:len() > self.max then
            return translations:gettext(self.msg):format(self.max)
        end
        return nil
    end
}}

local check_equal = {__index = {
    msg = 'The length must be exactly %d bytes.',
    validate = function(self, value, model, translations)
        if value and value:len() ~= self.min then
            return translations:gettext(self.msg):format(self.min)
        end
        return nil
    end
}}

local check_range = {__index = {
    msg = 'The length must fall within the range %d - %d bytes.',
    validate = function(self, value, model, translations)
        if value then
            local l = value:len()
            if l < self.min or l > self.max then
                return translations:gettext(self.msg):format(self.min, self.max)
            end
        end
        return nil
    end
}}

return function(o)
    if o.min then
        if not o.max then
            return setmetatable(o, check_min)
        elseif o.min == o.max then
            o.max = nil
            return setmetatable(o, check_equal)
        else
            return setmetatable(o, check_range)
        end
    elseif o.max then
        return setmetatable(o, check_max)
    else
        return succeed
    end
end
