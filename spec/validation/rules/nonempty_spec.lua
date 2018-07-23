local i18n = require 'core.i18n'
local nonempty = require 'validation.rules.nonempty'
local describe, it, assert = describe, it, assert

describe('nonempty rule', function()
    local translations = i18n.null

    it('succeeds', function()
        local r = nonempty()
        assert.is_nil(r:validate('x'))
    end)

    it('fails', function()
        local r = nonempty()
        assert(r:validate('', nil, translations))
    end)

    it('allows customize an error message', function()
        local r = nonempty {msg = 'error'}
        assert.equals('error', r:validate('', nil, translations))
    end)
end)
