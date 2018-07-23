local mixin = require 'core.mixin'
local i18n = require 'core.i18n'

local binder = require 'validation.binder'
local nonempty = require 'validation.rules.nonempty'
local required = require 'validation.rules.required'
local validator = require 'validation.validator'

local http = require 'http'


mixin(http.ResponseWriter, http.mixins.json)
mixin(http.Request, {
    translations = function(self)
        local cookies = self.cookies or self:parse_cookie()
        return self.options.translations[cookies['l'] or 'en']
    end
})

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

local app = http.app.new {
    translations = load_translations {'en', 'uk'}
}
app:use(http.middleware.routing)

local greeting_validator = validator.new {
    message = {required, nonempty}
}

-- lurl -X POST -H 'Cookie: l=uk' demos/http/i18n-validation.lua /
app:post('', function(w, req)
    local m = {message=''}
    local b = binder.new(req:translations())
    local values = req.body or req:parse_body()
    if not b:bind(m, values) or
            not b:validate(m, greeting_validator) then
        w:set_status_code(400)
        return w:json(b.errors)
    end
    return w:json(m)
end)

return app()
