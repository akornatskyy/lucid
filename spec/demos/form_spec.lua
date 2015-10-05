local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local json = require 'core.encoding.json'
local describe, it, assert = describe, it, assert

local function test_cases(app)
	assert.not_nil(app)

    it('responds with bad request status cod and errors', function()
        local w, req = writer.new(), request.new {method = 'POST'}
        app(w, req)
        assert.equals(400, w.status_code)
        assert.same({['Content-Type'] = 'application/json'}, w.headers)
        assert(json.decode(table.concat(w.buffer)))
	end)

    it('accepts a valid input', function()
        local w = writer.new()
        local req = request.new {
            method = 'POST',
            body = {
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
