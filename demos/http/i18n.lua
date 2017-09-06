local mixin = require 'core.mixin'
local http = require 'http'
local i18n = require 'core.i18n'

-- TODO: default_lang, fallback

mixin(http.Request, {
    translations = function(self)
        return self.options.translations[self.route_args.locale or 'en']
    end
})

local module = http.app.new()
module:get('days/{n:i}', function(w, req)
    local n = tonumber(req.route_args.n)
    if not n then
        return w:set_status_code(404)
    end
    local t = req:translations()
    return w:write(t:cgettext('%s day', n):format(n))
end)

local app = http.app.new()
app:add('{locale:(en|uk)}/', module)
app:use(http.middleware.routing)
app.options.translations = i18n.load {
    locales = {'en', 'uk'},
    directory = 'demos/locales/'
}

app:get('', function(w, req)
    return w:write(req:translations():gettext('Hello!\n'))
end)

return app()
