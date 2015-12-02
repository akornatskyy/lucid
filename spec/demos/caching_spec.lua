local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local describe, it, assert = describe, it, assert

local function test_cases(app)
	assert.not_nil(app)

	it('responds with a counter', function()
        for i=1, 10 do
            local w, req = writer.new(), request.new()
            app(w, req)
            assert.is_nil(w.status_code)
            assert.same('Counter = 1\n', w.buffer)
        end
	end)

	it('preserves status code', function()
        for i=1, 10 do
            local w, req = writer.new(), request.new {
                method = 'POST',
                path = '/not-found'
            }
            app(w, req)
            assert.equals(404, w.status_code)
            assert.same('Counter = 1\n', w.buffer)
        end
	end)
end

describe('demos.http.caching', function()
    test_cases(require 'demos.http.caching')
end)

describe('demos.web.caching', function()
    test_cases(require 'demos.web.caching')
end)
