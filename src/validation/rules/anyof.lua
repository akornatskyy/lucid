local initialize_rules = require 'validation.rules.initialize_rules'

local setmetatable = setmetatable


local check_rules = {__index = {
    validate = function(self, value, model, translations)
        local first_err
        local rules = self.rules
        for i = 1, #rules do
            local rule = rules[i]
            local err = rule:validate(value, model, translations)
            if err == nil then
                return nil
            elseif not first_err then
                first_err = err
            end
        end
        return first_err
    end
}}


return function(rules)
    return setmetatable({rules = initialize_rules(rules)}, check_rules)
end
