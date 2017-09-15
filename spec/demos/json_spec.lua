local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local describe, it, assert = describe, it, assert

local function test_cases(app)
	assert.not_nil(app)

	it('responds with hello', function()
        local w, req = writer.new(), request.new()
        app(w, req)
        assert.same({["Content-Type"] = "application/json"}, w.headers)
        assert.same({'{\"message\":\"Hello World!\"}'}, w.buffer)
	end)
end

describe('demos.http.json', function()
    test_cases(require 'demos.http.json')
end)

describe('demos.web.json', function()
    test_cases(require 'demos.web.json')
end)
