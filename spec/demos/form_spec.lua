local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local describe, it, assert = describe, it, assert

local function test_cases(app)
	assert.not_nil(app)

    it('responds with bad request status cod and errors', function()
        local w, req = writer.new(), request.new {method = 'POST'}
        app(w, req)
        assert.same({
            status_code = 400,
            headers = {['Content-Type'] = 'application/json'},
            buffer = {
                '{"message":"Required field cannot be left blank.",' ..
                '"author":"Required field cannot be left blank."}'
            }
        }, w)
	end)

    it('accepts a valid input', function()
        local w = writer.new()
        local req = request.new {
            method = 'POST',
            form = {
                author = 'jack', message = 'hello'
            }
        }
        app(w, req)
        assert.is_nil(w.status_code)
	end)
end

describe('demos.http.form', function()
    test_cases(require 'demos.http.form')
end)

describe('demos.web.form', function()
    test_cases(require 'demos.web.form')
end)
