local optional = require 'validation.rules.optional'
local describe, it, assert = describe, it, assert

describe('optional rule', function()

    it('succeeds if value is nil', function()
        local r = optional {}

        assert.is_nil(r:validate())
        assert.is_nil(r:validate('x'))
    end)

    it('calls inner rules and returns on first error', function()
        local r1 = {
            validate = function()
                return
            end
        }
        local r2 = {
            validate = function()
                return 'err1'
            end
        }
        local r3 = {
            validate = function()
                assert(false)
            end
        }
        local r = optional {r1, r2, r3}

        assert.equals('err1', r:validate('x'))
    end)
end)
