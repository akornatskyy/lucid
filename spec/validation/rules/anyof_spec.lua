local anyof = require 'validation.rules.anyof'
local describe, it, assert = describe, it, assert

describe('allof rule', function()

    it('succeeds if at least one rule succeeds', function()
        local c = 0
        local r1 = {
            validate = function()
                c = c + 1
                return 'err'
            end
        }
        local r2 = {
            validate = function()
            end
        }
        local r = anyof {r1, r1, r2, r1}

        assert.is_nil(r:validate())
        assert.equals(2, c)
    end)

    it('calls inner rules and returns on first error', function()
        local c = 0
        local r1 = {
            validate = function()
                c = c + 1
                return 'err1'
            end
        }
        local r2 = {
            validate = function()
                c = c + 1
                return 'err2'
            end
        }
        local r = anyof {r1, r2, r1, r2}

        assert.equals('err1', r:validate())
        assert.equals(4, c)
    end)
end)
