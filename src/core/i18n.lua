local json = require 'core.encoding.json'
local mixin = require 'core.mixin'
local plurals = require 'core.i18n.plurals'

local Translations = {
    gettext = function(self, msg)
        assert(type(msg) == 'string')
        return self.translations[msg] or msg
    end,

    cardinal = function(n)
        assert(type(n) == 'number')
        return n == 1 and 'one' or 'other'
    end,

    cgettext = function(self, msg, n)
        local m = self.translations[msg]
        if not m then
            return msg
        end
        return m[self.cardinal(n)] or m['other'] or msg
    end,

    ordinal = function(n)
        assert(type(n) == 'number')
        return n == 1 and 'one' or 'other'
    end,

    ogettext = function(self, msg, n)
        local m = self.translations[msg]
        if not m then
            return msg
        end
        return m[self.ordinal(n)] or m['other'] or msg
    end
}

local null = {
    gettext = function(self, msg)
        assert(self)
        assert(msg)
        return msg
    end,

    cgettext = function(self, msg, n)
        assert(self)
        assert(msg)
        assert(n)
        return msg
    end,

    ogettext = function(self, msg, n)
        assert(self)
        assert(msg)
        assert(n)
        return msg
    end
}

local function new(self)
    assert(type(self) == 'table')
    assert(type(self.translations))
    return setmetatable(self, {
        __index = mixin({}, Translations, plurals.rules[self.lang])
    })
end

local load_json = function(path)
    local f = assert(io.open(path, 'rb'))
    local content = f:read '*a'
    f:close()
    return json.decode(content)
end

local function load(options)
    local t = {}
    for _, l in next, options.locales do
        t[l] = new {
            translations = load_json(options.directory .. l .. '.json'),
            lang = l
        }
    end
    return t
end

return {
    new = new,
    load = load,
    null = null
}
