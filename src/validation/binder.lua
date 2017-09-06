local setmetatable = setmetatable
local update_model
local null_translations

do
    local i18n = require 'core.i18n'
    local model = require 'validation.model'
    update_model = model.update_model
    null_translations = i18n.null
end

local Binder = {}
local mt = {__index=Binder}

local function new(translations)
    return setmetatable({
        errors = {},
        translations = translations or null_translations
    }, mt)
end

function Binder:bind(model, values)
    return update_model(model, values, self.errors, self.translations)
end

function Binder:validate(model, validator)
    return validator:validate(model, self.errors, self.translations)
end

return {
    new = new
}
