local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local describe, it, assert = describe, it, assert

local function test_cases(app)
	assert.not_nil(app)

	it('responds with hi', function()
        local w, req = writer.new(), request.new {path = '/greetings/hi'}
        app(w, req)
        assert.same({'hi'}, w.buffer)
	end)
end

describe('demos.http.hello', function()
    test_cases(require 'demos.http.composable')
end)

describe('demos.web.hello', function()
    test_cases(require 'demos.web.composable')
end)
