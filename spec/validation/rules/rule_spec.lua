local rule = require 'validation.rules.rule'
local describe, it, assert, spy = describe, it, assert, spy

describe('custom rule', function()

    it('calls custom function and passes all arguments', function()
        local s = spy.new(function() end)
        local r = rule(function(...) s(...) end)

        assert.is_nil(r:validate(1, 2, 3))

        assert.spy(s).called_with(1, 2, 3)
    end)

    it('calls custom function and returns an error', function()
        local r = rule(function() return 'err' end)

        assert.equals('err', r:validate())
    end)
end)
