local null_translations

do
    local i18n = require 'core.i18n'
    null_translations = i18n.null
end

local Mixin = {
    translations = {}
}

function Mixin:validate(model, validator)
    -- self.errors and self:get_locale() must exist
    return validator:validate(
        model,
        self.errors,
        self.translations[self:get_locale()] or null_translations)
end

return Mixin
