local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local describe, it, assert = describe, it, assert

local function test_cases(app)
	assert.not_nil(app)

	it('responds with BA', function()
        local w, req = writer.new(), request.new()
        app(w, req)
        assert.same({'B', 'A'}, w.buffer)
	end)
end

describe('demos.http.middleware', function()
    test_cases(require 'demos.http.middleware')
end)

describe('demos.web.middleware', function()
    test_cases(require 'demos.web.middleware')
end)
