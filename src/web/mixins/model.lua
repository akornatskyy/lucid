local defaulttable = require 'core.collections.defaulttable'


local update_model
local translation

do
    local i18n = require 'core.i18n'
    local model = require 'validation.model'
    update_model = model.update_model
    translation = i18n.NullTranslation
end

local Mixin = {
    translation = defaulttable(function() return translation end)
}

function Mixin:get_locale()
    return self.req.route_args.locale or ''
end

function Mixin:update_model(model, values)
    -- self.errors must exist
    local req = self.req
    return update_model(model, values or req.form or req:parse_form(),
                        self.errors, self.translation[self:get_locale()])
end

function Mixin:validate(model, validator)
    -- self.errors must exist
    return validator:validate(model, self.errors,
                              self.translation[self:get_locale()])
end

return Mixin
