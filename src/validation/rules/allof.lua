local initialize_rules = require 'validation.rules.initialize_rules'

local setmetatable = setmetatable


local check_rules = {__index = {
    validate = function(self, value, model, translations)
        local rules = self.rules
        for i = 1, #rules do
            local rule = rules[i]
            local err = rule:validate(value, model, translations)
            if err then
                return err
            end
        end
        return nil
    end
}}


return function(rules)
    return setmetatable({rules = initialize_rules(rules)}, check_rules)
end
