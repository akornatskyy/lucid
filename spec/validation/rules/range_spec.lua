local i18n = require 'core.i18n'
local range = require 'validation.rules.range'
local describe, it, assert = describe, it, assert

describe('range rule', function()
    local translations = i18n.null

    describe('check min', function()
        local r = range{min=1}

        it('ignores nil value', function()
            assert.is_nil(r:validate(nil))
        end)

        it('succeeds', function()
            assert.is_nil(r:validate(1))
            assert.is_nil(r:validate(10.5))
        end)

        it('fails', function()
            assert(r:validate(0, nil, translations))
            assert(r:validate(-10, nil, translations))
        end)
    end)

    describe('check max', function()
        local r = range{max=2}

        it('ignores nil value', function()
            assert.is_nil(r:validate(nil))
        end)

        it('succeeds', function()
            assert.is_nil(r:validate(0))
            assert.is_nil(r:validate(-5.2))
            assert.is_nil(r:validate(2))
        end)

        it('fails', function()
            assert(r:validate(2.1, nil, translations))
            assert(r:validate(10, nil, translations))
        end)
    end)

    describe('check equal', function()
        local r = range{min=2, max=2}

        it('ignores nil value', function()
            assert.is_nil(r:validate(nil))
        end)

        it('succeeds', function()
            assert.is_nil(r:validate(2))
        end)

        it('fails', function()
            assert(r:validate(1, nil, translations))
            assert(r:validate(3, nil, translations))
        end)
    end)

    describe('check range', function()
        local r = range{min=1, max=2}

        it('ignores nil value', function()
            assert.is_nil(r:validate(nil))
        end)

        it('succeeds', function()
            assert.is_nil(r:validate(1))
            assert.is_nil(r:validate(1.5))
            assert.is_nil(r:validate(2))
        end)

        it('fails', function()
            assert(r:validate(0, nil, translations))
            assert(r:validate(0.9, nil, translations))
            assert(r:validate(2.1, nil, translations))
            assert(r:validate(5, nil, translations))
        end)
    end)

    it('always succeeds if min nor max specified', function()
        local r = range{}
        assert.is_nil(r:validate(100))
    end)
end)
