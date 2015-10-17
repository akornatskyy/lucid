local i18n = require 'core.i18n'
local email = require 'validation.rules.email'
local describe, it, assert = describe, it, assert

describe('email rule', function()
    local translations = i18n.NullTranslation
    local r = email()

    it('ignores nil value', function()
        assert.is_nil(r:validate())
    end)

    it('succeeds', function()
        assert.is_nil(r:validate('x.14@somewhere.org'))
    end)

    it('fails', function()
        assert(r:validate('x', nil, translations))
    end)

    it('allows customize an error message', function()
        local e = email{msg = 'error'}
        assert.equals('error', e:validate('', nil, translations))
    end)
end)
