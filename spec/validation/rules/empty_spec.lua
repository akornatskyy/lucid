local i18n = require 'core.i18n'
local empty = require 'validation.rules.empty'
local describe, it, assert = describe, it, assert

describe('empty rule', function()
    local translations = i18n.null

    describe('check shortcut', function()
        local r = empty()

        it('succeeds', function()
            assert.is_nil(r:validate(''))
        end)

        it('fails', function()
            assert(r:validate('x', nil, translations))
        end)
    end)

    describe('check is empty', function()
        local r = empty {msg = 'error'}

        it('succeeds', function()
            assert.is_nil(r:validate(''))
        end)

        it('fails', function()
            assert.equals('error', r:validate('x', nil, translations))
        end)
    end)
end)
