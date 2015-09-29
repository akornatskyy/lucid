local defaulttable = require 'core.collections.defaulttable'
local assert, setmetatable = assert, setmetatable

local NullTranslation = {
    gettext = function(self, msg)
        assert(self)
        return msg
    end,
    ngettext = function(self, msg1, msg2, n)
        assert(self)
        return n == 1 and msg1 or msg2
    end
}

local function make_translation()
    return NullTranslation
end

local function make_domain()
    return defaulttable(make_translation)
end

local Manager = {
    ctor = function(self, directories, default_lang)
        self.default_lang = default_lang or 'en'
        self.domains = defaulttable(make_domain)
        self.locale = {}
        if directories then
            for _, d in next, directories do
                assert(self.load(d))
            end
        end
    end,

    load = function(self, directory)
        assert(self)
        assert(directory)
    end
}

local mt = {__index=Manager}

local function new(...)
    local self = setmetatable({}, mt)
    self:ctor(...)
    return self
end

return {
    configure = new,
    NullTranslation = NullTranslation
}
