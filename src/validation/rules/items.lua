local initialize_rules = require 'validation.rules.initialize_rules'

local setmetatable, next = setmetatable, next


local check_items = {__index = {
    validate = function(self, value, model, translations)
        local rules = self.rules
        for _, item in next, value do
            for _, rule in next, rules do
                local err = rule:validate(item, model, translations)
                if err then
                    return err
                end
            end
        end
        return nil
    end
}}


return function(rules)
    return setmetatable({rules = initialize_rules(rules)}, check_items)
end
