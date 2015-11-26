local principal = require 'web.mixins.principal'
local describe, it, assert, setmetatable = describe, it, assert, setmetatable

describe('web.mixins.principal', function()
    describe('get principal', function()
	    it('returns saved principal', function()
		    local c = setmetatable({}, {__index=principal})
            c.principal = 'x'
            assert.equals('x', c:get_principal())
	    end)
    end)
end)
