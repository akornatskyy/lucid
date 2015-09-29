local update_model
local null_translation

do
    local i18n = require 'core.i18n'
    local model = require 'validation.model'
    update_model = model.update_model
    null_translation = i18n.NullTranslation
end

local Binder = {}
local mt = {__index=Binder}

local function new(translation)
    return setmetatable({
        errors = {},
        translation=translation or null_translation
    }, mt)
end

function Binder:bind(model, values)
    return update_model(model, values, self.errors, self.translation)
end

function Binder:validate(model, validator)
    return validator:validate(model, self.errors, self.translation)
end

return {
    new = new
}

