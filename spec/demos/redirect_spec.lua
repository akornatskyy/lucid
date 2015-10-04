local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local describe, it, assert = describe, it, assert

local function test_cases(app)
	assert.not_nil(app)

	it('responds with moved temporarily status code', function()
        local w, req = writer.new(), request.new()
        app(w, req)
        assert.equals(302, w.status_code)
        assert.same({['Location'] = 'http://localhost:8080/welcome'},
                    w.headers)
	end)

    it('follows redirect', function()
        local w, req = writer.new(), request.new {path = '/welcome'}
        app(w, req)
        assert.same({'Hello World!\n'}, w.buffer)
    end)
end

describe('demos.http.redirect', function()
    test_cases(require 'demos.http.redirect')
end)

describe('demos.web.redirect', function()
    test_cases(require 'demos.web.redirect')
end)
