local helloworld = require 'http.adapters.nginx.helloworld'
local describe, it, assert = describe, it, assert

describe('http.adapters.nginx.helloworld', function()
	it('', function()
		assert.not_nil(helloworld)
	end)
end)
