local i18n = require 'core.i18n'
local nilable = require 'validation.rules.nilable'
local describe, it, assert = describe, it, assert

describe('nilable rule', function()
    local translations = i18n.null

    it('succeeds', function()
        local r = nilable()
        assert.is_nil(r:validate())
    end)

    it('fails', function()
        local r = nilable()
        assert(r:validate('', nil, translations))
    end)

    it('allows customize an error message', function()
        local r = nilable {msg = 'error'}
        assert.equals('error', r:validate('', nil, translations))
    end)
end)
