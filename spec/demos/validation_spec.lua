local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local json = require 'core.encoding.json'
local describe, it, assert = describe, it, assert

local function test_cases(app)
	assert.not_nil(app)

	it('responds with message', function()
        local w, req = writer.new(), request.new {
			method = 'POST',
			body = {message = 'hello', author=''}
		}
        app(w, req)
        assert.is_nil(w.status_code)
	end)

    it('responds with errors', function()
		local w, req = writer.new(), request.new {
			method = 'POST'
		}
        app(w, req)
		assert.equals(400, w.status_code)
        assert.same({['Content-Type'] = 'application/json'}, w.headers)
        assert(json.decode(table.concat(w.buffer)))
    end)
end

describe('demos.http.validation', function()
    test_cases(require 'demos.http.validation')
end)

describe('demos.web.validation', function()
    test_cases(require 'demos.web.validation')
end)
