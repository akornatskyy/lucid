local i18n = require 'core.i18n'
local nonempty = require 'validation.rules.nonempty'
local describe, it, assert = describe, it, assert

describe('empty rule', function()
    local translations = i18n.null

    describe('check shortcut', function()
        local r = nonempty()

        it('succeeds', function()
            assert.is_nil(r:validate('x'))
        end)

        it('fails', function()
            assert(r:validate('', nil, translations))
        end)
    end)

    describe('check is not empty', function()
        local r = nonempty {msg = 'error'}

        it('succeeds', function()
            assert.is_nil(r:validate('x'))
        end)

        it('fails', function()
            assert.equals('error', r:validate('', nil, translations))
        end)
    end)
end)
