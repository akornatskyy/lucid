local class = require 'core.class'
local mixin = require 'core.mixin'
local i18n = require 'core.i18n'

local nonempty = require 'validation.rules.nonempty'
local required = require 'validation.rules.required'
local validator = require 'validation.validator'

local web = require 'web'

local greeting_validator = validator.new {
    message = {required, nonempty}
}

local function load_translations(locales)
    local t = {}
    for _, l in next, locales do
        t[l] = i18n.new {
            translations = assert(require('validation.rules.messages.' .. l)),
            lang = l
        }
    end
    return t
end

local BaseHandler = {}
mixin(BaseHandler, web.mixins.json, web.mixins.validation, web.mixins.model)
mixin(BaseHandler, {
    translations = load_translations {'en', 'uk'},

    get_locale = function(self)
        local cookies = self.cookies or self.req:parse_cookie()
        return cookies['l'] or 'en'
    end
})


local WelcomeHandler = class(BaseHandler, {
  post = function(self)
      local m = {message=''}
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
        {'', WelcomeHandler}
    }
})
