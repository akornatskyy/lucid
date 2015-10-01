local authcookie = require 'http.middleware.authcookie'
local describe, it, assert = describe, it, assert

describe('http.middleware.authcookie', function()
	it('', function()
		assert.not_nil(authcookie)
	end)
end)
