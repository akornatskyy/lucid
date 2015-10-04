local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local describe, it, assert = describe, it, assert

local function test_cases(app)
	assert.not_nil(app)

	it('responds with absolute url for user', function()
        local w, req = writer.new(), request.new {path = '/en/user/123'}
        app(w, req)
        assert.same({'http://localhost:8080/en/user/123\n'}, w.buffer)
	end)
end

describe('demos.http.routing', function()
    test_cases(require 'demos.http.routing')
end)

describe('demos.web.routing', function()
    test_cases(require 'demos.web.routing')
end)
