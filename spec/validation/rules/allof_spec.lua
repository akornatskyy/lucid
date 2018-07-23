local allof = require 'validation.rules.allof'
local describe, it, assert = describe, it, assert

describe('allof rule', function()

    it('succeeds if all rules succeed', function()
        local c = 0
        local r1 = {
            validate = function()
                c = c + 1
            end
        }
        local r = allof {r1, r1, r1}

        assert.is_nil(r:validate())
        assert.equals(3, c)
    end)

    it('calls inner rules and returns on first error', function()
        local r1 = {
            validate = function()
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
        local r = allof {r1, r2, r3}

        assert.equals('err1', r:validate('x'))
    end)
end)
