local succeed = require 'validation.rules.succeed'

local describe, it, assert = describe, it, assert

describe('succeed validate', function()

    it('returns nil', function()
        local r = succeed
        assert.is_nil(r:validate())
    end)
end)
