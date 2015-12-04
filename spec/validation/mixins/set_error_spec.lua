local set_error = require 'validation.mixins.set_error'
local describe, it, assert = describe, it, assert

describe('validation.mixins.set_error', function()
	it('sets general error message', function()
		local m = setmetatable({errors={}}, {__index=set_error})
        m:set_error('message')
        assert.equals('message', m.errors.__ERROR__)
	end)

    it('sets field error message', function()
		local m = setmetatable({errors={}}, {__index=set_error})
        m:set_error('message', 'field')
        assert.equals('message', m.errors.field)
	end)
end)
