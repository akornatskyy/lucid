local i18n = require 'core.i18n'
local typeof = require 'validation.rules.typeof'
local describe, it, assert = describe, it, assert

describe('typeof rule', function()
    local translations = i18n.null

    describe('check shortcut with string', function()
        local r = typeof 'boolean'

        it('succeeds', function()
            assert.is_nil(r:validate(true))
            assert.is_nil(r:validate(false))
        end)

        it('fails', function()
            assert(r:validate('x', nil, translations))
        end)
    end)

    describe('check shortcut with customer error message', function()
        local r = typeof {'boolean', msg = 'error'}

        it('succeeds', function()
            assert.is_nil(r:validate(false))
        end)

        it('fails', function()
            assert.equals('error', r:validate('x', nil, translations))
        end)
    end)

    describe('check standard type', function()
        local r = typeof {type = 'number', msg = 'error'}

        it('succeeds', function()
            assert.is_nil(r:validate(-123.4))
            assert.is_nil(r:validate(0))
            assert.is_nil(r:validate(123))
            assert.is_nil(r:validate(123.4))
        end)

        it('fails', function()
            assert.equals('error', r:validate('x', nil, translations))
        end)
    end)

    describe('check integer type', function()
        local r = typeof {type = 'integer', msg = 'error'}

        it('succeeds', function()
            assert.is_nil(r:validate(-123))
            assert.is_nil(r:validate(0))
            assert.is_nil(r:validate(123))
        end)

        it('fails', function()
            assert.equals('error', r:validate(123.4, nil, translations))
        end)
    end)
end)
