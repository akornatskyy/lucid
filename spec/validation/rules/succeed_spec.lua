local succeed = require 'validation.rules.succeed'
local describe, it, assert, setmetatable = describe, it, assert, setmetatable

describe('succeed validate', function()

    it('returns nil', function()
        local r = setmetatable({}, succeed)
        assert.is_nil(r:validate())
    end)
end)
