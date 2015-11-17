local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local describe, it, assert = describe, it, assert

local function test_cases(app)
	assert.not_nil(app)

	it('responds with cookie', function()
        local w, req = writer.new(), request.new()
        app(w, req)
        assert.same({
            'm=hello; Path=/',
            'c=100; HttpOnly',
            'x=5'
        }, w.headers['Set-Cookie'])
	end)

	it('removes cookie', function()
        local w, req = writer.new(), request.new {path = '/remove'}
        app(w, req)
        assert.same('c=; Expires=Thu, 01 Jan 1970 00:00:00 GMT',
                    w.headers['Set-Cookie'])
	end)
end

describe('demos.http.cookies', function()
    test_cases(require 'demos.http.cookies')
end)

describe('demos.web.cookies', function()
    test_cases(require 'demos.web.cookies')
end)
