local i18n = require 'core.i18n'
local bytes = require 'validation.rules.bytes'
local describe, it, assert = describe, it, assert

describe('bytes rule', function()
    local translations = i18n.NullTranslation

    describe('check min', function()
        local r = bytes{min=1}

        it('ignores nil value', function()
            assert.is_nil(r:validate(nil))
        end)

        it('succeeds', function()
            assert.is_nil(r:validate('x'))
            assert.is_nil(r:validate('xx'))
        end)

        it('fails', function()
            assert(r:validate('', nil, translations))
        end)
    end)

    describe('check max', function()
        local r = bytes{max=2}

        it('ignores nil value', function()
            assert.is_nil(r:validate(nil))
        end)

        it('succeeds', function()
            assert.is_nil(r:validate(''))
            assert.is_nil(r:validate('x'))
            assert.is_nil(r:validate('xx'))
        end)

        it('fails', function()
            assert(r:validate('xxx', nil, translations))
        end)
    end)

    describe('check equal', function()
        local r = bytes{min=2, max=2}

        it('ignores nil value', function()
            assert.is_nil(r:validate(nil))
        end)

        it('succeeds', function()
            assert.is_nil(r:validate('xx'))
        end)

        it('fails', function()
            assert(r:validate('x', nil, translations))
            assert(r:validate('xxx', nil, translations))
        end)
    end)

    describe('check range', function()
        local r = bytes{min=1, max=2}

        it('ignores nil value', function()
            assert.is_nil(r:validate(nil))
        end)

        it('succeeds', function()
            assert.is_nil(r:validate('x'))
            assert.is_nil(r:validate('xx'))
        end)

        it('fails', function()
            assert(r:validate('', nil, translations))
            assert(r:validate('xxx', nil, translations))
        end)
    end)

    it('always succeeds if min nor max specified', function()
        local r = bytes{}
        assert.is_nil(r:validate(''))
    end)
end)
