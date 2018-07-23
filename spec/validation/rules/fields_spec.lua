local i18n = require 'core.i18n'
local fields = require 'validation.rules.fields'
local describe, it, assert = describe, it, assert

describe('fields rule', function()
    local translations = i18n.null

    it('succeeds', function()
        local r = fields {'a', 'b'}

        assert.is_nil(r:validate(nil, {a = 1}))
    end)

    it('fails with unknown field error', function()
        local r = fields {'a', 'b'}

        local err = r:validate(nil, {a = 1, c = 2}, translations)

        assert.equals('Unknown field name [c].', err)
    end)

    it('truncates a long field name', function()
        local r = fields {'a'}

        local err = r:validate(nil, {[string.rep('long', 4)] = 2}, translations)

        assert.equals('Unknown field name [longlongl].', err)
    end)

    it('allows customize an error message', function()
        local r = fields {allowed = {'a'}, msg = 'error'}

        assert.equals('error', r:validate(nil, {b = 1}, translations))
    end)
end)
