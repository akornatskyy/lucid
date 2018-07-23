local items = require 'validation.rules.items'
local describe, it, assert = describe, it, assert

describe('items rule', function()
    it('calls each inner rule for each item', function()
        local c = 0
        local r1 = {
            validate = function()
                c = c + 1
            end
        }
        local r = items {r1, r1, r1}

        assert.is_nil(r:validate({1, 2, 3, 4}))
        assert.equals(12, c)
    end)

    it('calls each inner rule and returns on first error', function()
        local c = 0
        local r1 = {
            validate = function(_, value)
                c = c + 1
                if value >= 3 then
                    return 'err' .. value
                end
            end
        }
        local r = items {r1, r1, r1}

        assert.equals('err3', r:validate({1, 2, 3, 4}))
        assert.equals(7, c)
    end)
end)
