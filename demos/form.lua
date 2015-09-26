local mixin = require 'core.mixin'
local i18n = require 'core.i18n'
local length = require 'validation.rules.length'
local required = require 'validation.rules.required'
local validator = require 'validation.validator'
local http = require 'http'
local web = require 'web'
_ENV = nil

-- models

i18n = i18n.configure()

-- validation

local greeting_validator = validator.new({
    author = {required, length{max=20}},
    message = {required, length{min=5}, length{max=512}}
})

-- handlers

local BaseHandler = mixin({
    translation = i18n.domains['demo']
}, web.mixins.JSONMixin, web.mixins.ModelMixin)


local FormHandler = mixin({}, BaseHandler)

-- curl -i --data "author=John&message=hello" http://127.0.0.1:8080
function FormHandler:post()
    local m = {author='', message=''}
    self.errors = {}
    if not self:update_model(m) or
            not self:validate(m, greeting_validator) then
        return self:json_errors()
    end
    return self:json({message='Hello, ' .. m.author})
end

-- url mapping

local all_urls = {
    {'', {__index = FormHandler}}
}

-- config

local options = {
    urls = all_urls
}

return http.app({web.middleware.routing}, options)
