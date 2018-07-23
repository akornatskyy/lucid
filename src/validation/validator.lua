local initialize_rules = require 'validation.rules.initialize_rules'

local next, setmetatable = next, setmetatable


local function validate(self, model, errors, translations)
    local ok = true
    for name, rules in next, self.mapping do
        local value = model[name]
        for _, r in next, rules do
            local err = r:validate(value, model, translations)
            if err then
                ok = false
                errors[name] = err
                break
            end
        end
    end
    return ok
end

local function validate_composite(self, model, errors, translations)
    local ok = validate(self, model, errors, translations)
    for name, validator in next, self.validators do
        if not validator:validate(model[name], errors, translations) then
            ok = false
        end
    end
    return ok
end

local validator = {
    __index = {
        validate = validate
    }
}

local composite = {
    __index = {
        validate = validate_composite
    }
}

local new = function(mapping)
    local nested = false
    local v = {}
    local m = {}
    for name, rules in next, mapping do
        if rules.validate then
            nested = true
            v[name] = rules
        else
            m[name] = initialize_rules(rules)
        end
    end
    if nested then
        return setmetatable({mapping = m, validators = v}, composite)
    else
        return setmetatable({mapping = m}, validator)
    end
end

return {
    new = new
}
