local update_model
local null_translations

do
    local i18n = require 'core.i18n'
    local model = require 'validation.model'
    update_model = model.update_model
    null_translations = i18n.null
end

local Mixin = {
    translations = {}
}

function Mixin:update_model(model, values)
    -- self.errors and self:get_locale() must exist
    local req = self.req
    return update_model(
        model,
        values or req.body or req:parse_body(),
        self.errors,
        self.translations[self:get_locale()] or null_translations)
end

return Mixin
