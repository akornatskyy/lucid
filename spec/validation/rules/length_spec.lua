local i18n = require 'core.i18n'
local length = require 'validation.rules.length'
local describe, it, assert = describe, it, assert

describe('length rule', function()
    local translations = i18n.null

    describe('check min', function()
        local r = length{min=1}

        it('ignores nil value', function()
            assert.is_nil(r:validate(nil))
        end)

        it('succeeds', function()
            assert.is_nil(r:validate('x'))
            assert.is_nil(r:validate('嗨'))
            assert.is_nil(r:validate('xx'))
            assert.is_nil(r:validate('你好'))
        end)

        it('fails', function()
            assert(r:validate('', nil, translations))
        end)
    end)

    describe('check max', function()
        local r = length{max=2}

        it('ignores nil value', function()
            assert.is_nil(r:validate(nil))
        end)

        it('succeeds', function()
            assert.is_nil(r:validate(''))
            assert.is_nil(r:validate('x'))
            assert.is_nil(r:validate('嗨'))
            assert.is_nil(r:validate('xx'))
            assert.is_nil(r:validate('你好'))
        end)

        it('fails', function()
            assert(r:validate('xxx', nil, translations))
            assert(r:validate('早上好', nil, translations))
        end)
    end)

    describe('check equal', function()
        local r = length{min=2, max=2}

        it('ignores nil value', function()
            assert.is_nil(r:validate(nil))
        end)

        it('succeeds', function()
            assert.is_nil(r:validate('xx'))
            assert.is_nil(r:validate('你好'))
        end)

        it('fails', function()
            assert(r:validate('x', nil, translations))
            assert(r:validate('嗨', nil, translations))
            assert(r:validate('xxx', nil, translations))
            assert(r:validate('早上好', nil, translations))
        end)
    end)

    describe('check range', function()
        local r = length{min=1, max=2}

        it('ignores nil value', function()
            assert.is_nil(r:validate(nil))
        end)

        it('succeeds', function()
            assert.is_nil(r:validate('x'))
            assert.is_nil(r:validate('嗨'))
            assert.is_nil(r:validate('xx'))
            assert.is_nil(r:validate('你好'))
        end)

        it('fails', function()
            assert(r:validate('', nil, translations))
            assert(r:validate('xxx', nil, translations))
            assert(r:validate('早上好', nil, translations))
        end)
    end)

    it('always succeeds if min nor max specified', function()
        local r = length{}
        assert.is_nil(r:validate(''))
    end)
end)
