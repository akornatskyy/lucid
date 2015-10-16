local defaulttable = require 'core.collections.defaulttable'


local translation

do
    local i18n = require 'core.i18n'
    translation = i18n.NullTranslation
end

local Mixin = {
    translation = defaulttable(function() return translation end)
}

function Mixin:validate(model, validator)
    -- self.errors and self:get_locale() must exist
    return validator:validate(model, self.errors,
                              self.translation[self:get_locale()])
end

return Mixin
