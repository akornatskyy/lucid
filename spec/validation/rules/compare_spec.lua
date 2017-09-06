local i18n = require 'core.i18n'
local compare = require 'validation.rules.compare'
local describe, it, assert = describe, it, assert

describe('compare rule', function()
    local translations = i18n.null

    describe('check equal', function()
        local r = compare{equal='confirm_password', msg='error'}
        local m = {confirm_password = 'x'}

        it('succeeds', function()
            assert.is_nil(r:validate('x', m))
        end)

        it('fails', function()
            assert.equals('error', r:validate('xx', m, translations))
        end)
    end)

    describe('check not equal', function()
        local r = compare{not_equal='previous_password'}
        local m = {previous_password = 'x'}

        it('succeeds', function()
            assert.is_nil(r:validate('xx', m))
        end)

        it('fails', function()
            assert(r:validate('x', m, translations))
        end)
    end)

    it('always succeeds if equal nor not_equal specified', function()
        local r = compare{}
        assert.is_nil(r:validate())
    end)
end)
