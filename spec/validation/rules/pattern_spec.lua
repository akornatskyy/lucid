local i18n = require 'core.i18n'
local pattern = require 'validation.rules.pattern'
local describe, it, assert = describe, it, assert

describe('pattern rule', function()
    local translations = i18n.NullTranslation

    describe('check found', function()
        local r = pattern{'%d+'}

        it('ignores nil value', function()
            assert.is_nil(r:validate())
        end)

        it('succeeds', function()
            assert.is_nil(r:validate('1'))
        end)

        it('fails', function()
            assert(r:validate('x', nil, translations))
        end)

        it('allows customize an error message', function()
            local p = pattern{pattern ='%d', msg = 'error'}
            assert.equals('error', p:validate('', nil, translations))
        end)
    end)

    describe('check plain found', function()
        local r = pattern{'fox', plain=true}

        it('succeeds', function()
            assert.is_nil(r:validate('firefox'))
        end)

        it('fails', function()
            assert(r:validate('bird', nil, translations))
        end)
    end)

    describe('check not found', function()
        local r = pattern{'%s', negated=true}

        it('ignores nil value', function()
            assert.is_nil(r:validate())
        end)

        it('succeeds', function()
            assert.is_nil(r:validate('x'))
        end)

        it('fails', function()
            assert(r:validate('x x', nil, translations))
        end)

        it('allows customize an error message', function()
            local p = pattern{pattern ='%s', negated=true, msg = 'error'}
            assert.equals('error', p:validate(' ', nil, translations))
        end)
    end)

    describe('check plain not found', function()
        local r = pattern{'fox', plain=true, negated=true}

        it('succeeds', function()
            assert.is_nil(r:validate('bird'))
        end)

        it('fails', function()
            assert(r:validate('firefox', nil, translations))
        end)
    end)
end)
