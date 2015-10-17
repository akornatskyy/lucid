local succeed = require 'validation.rules.succeed'
local setmetatable = setmetatable


local check_min = {__index = {
    msg = 'Required to be greater or equal to %d.',
    validate = function(self, value, model, translations)
        if value and value < self.min then
            return translations:gettext(self.msg):format(self.min)
        end
        return nil
    end
}}

local check_max = {__index = {
    msg = 'Exceeds maximum allowed value of %d.',
    validate = function(self, value, model, translations)
        if value and value > self.max then
            return translations:gettext(self.msg):format(self.max)
        end
        return nil
    end
}}

local check_equal = {__index = {
    msg = 'The value must be exactly %d.',
    validate = function(self, value, model, translations)
        if value and value ~= self.min then
            return translations:gettext(self.msg):format(self.min)
        end
        return nil
    end
}}

local check_range = {__index = {
    msg = 'The value must fall within the range %d - %d.',
    validate = function(self, value, model, translations)
        if value and (value < self.min or value > self.max) then
            return translations:gettext(self.msg):format(self.min, self.max)
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
        return setmetatable(o, succeed)
    end
end
