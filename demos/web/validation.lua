local class = require 'core.class'
local mixin = require 'core.mixin'

local validator = require 'validation.validator'
local length = require 'validation.rules.length'
local required = require 'validation.rules.required'

local web = require 'web'

local greeting_validator = validator.new {
    author = {length{max=20}},
    message = {required, length{min=5}, length{max=512}}
}

local BaseHandler = {}
mixin(BaseHandler, web.mixins.json, web.mixins.locale, web.mixins.validation,
      web.mixins.model)

local FormHandler = class(BaseHandler, {
  post = function(self)
      local m = {author='', message=''}
      self.errors = {}
      if not self:update_model(m) or
              not self:validate(m, greeting_validator) then
          return self:json_errors()
      end
      return self:json(m)
  end
})

return web.app({web.middleware.routing}, {
    urls = {
        {'', FormHandler}
    }
})
