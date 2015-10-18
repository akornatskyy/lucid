local i18n = require 'core.i18n'
local required = require 'validation.rules.required'
local describe, it, assert = describe, it, assert

describe('required rule', function()
    local translations = i18n.NullTranslation

    it('succeeds', function()
        local r = required()
        assert.is_nil(r:validate('x'))
    end)

    it('fails', function()
        local r = required()
        assert(r:validate(nil, nil, translations))
        assert(r:validate(false, nil, translations))
        assert(r:validate('', nil, translations))
    end)

    it('allows customize an error message', function()
        local r = required{msg = 'error'}
        assert.equals('error', r:validate(nil, nil, translations))
    end)
end)
