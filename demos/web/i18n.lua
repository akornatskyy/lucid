local class = require 'core.class'
local mixin = require 'core.mixin'
local i18n = require 'core.i18n'
local web = require 'web'


local BaseHandler = mixin ({}, web.mixins.locale, {
    translations = i18n.load {
        locales = {'en', 'uk'},
        directory = 'demos/locales/'
    },

    gettext = function(self, msg)
        local t = self.translations[self:get_locale()] or i18n.null
        return t:gettext(msg)
    end,

    cgettext = function(self, msg, n)
        local t = self.translations[self:get_locale()] or i18n.null
        return t:cgettext(msg, n)
    end
})

local DayHandler = class(BaseHandler, {
    get = function(self)
        local n = tonumber(self.req.route_args.n)
        if not n then
            return self.w:set_status_code(404)
        end
        return self.w:write(self:cgettext('%s day', n):format(n))
    end
})

local WelcomeHandler = class(BaseHandler, {
    get = function(self)
        return self.w:write(self:gettext('Hello!\n'))
    end
})

return web.app({web.middleware.routing}, {
    urls = {
        {'', WelcomeHandler},
        {
            '{locale:(en|uk)}/', {
                {'days/{n:i}', DayHandler}
            }
        }
    }
})
