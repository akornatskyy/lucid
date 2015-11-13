local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local describe, it, assert = describe, it, assert

local function test_cases(app)
	assert.not_nil(app)

	it('responds with hello', function()
        local w, req = writer.new(), request.new()
        app(w, req)
        assert.same({'Hello World!\n'}, w.buffer)
	end)

    it('responds with method not allowed status code', function()
        local http_verbs = {
            'DELETE', 'HEAD', 'OPTIONS', 'PATCH', 'POST', 'PUT', 'UNKNOWN'
        }
        for _, m in next, http_verbs do
                local w, req = writer.new(), request.new {method = m}
                app(w, req)
                assert.equals(405, w.status_code)
        end
    end)
end

describe('demos.http.hello', function()
    test_cases(require 'demos.http.hello')
end)

describe('demos.web.hello', function()
    test_cases(require 'demos.web.hello')
end)
