local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local describe, it, assert = describe, it, assert

local function test_cases(app)
	assert.not_nil(app)

	it('responds with message', function()
        local w, req = writer.new(), request.new {
			method = 'POST',
			body = {message = 'hello'}
		}
        app(w, req)
        assert.is_nil(w.status_code)
	end)

    it('responds with errors', function()
		local samples = {
            {'{"message":"Required field cannot be left blank."}', ''},
            {'{"message":"Required field cannot be left blank."}', 'en'},
            {'{"message":"Required field cannot be left blank."}', 'de'},
            {'{"message":"Обов\'язкове поле не може бути порожнім."}', 'uk'}
        }
        for _, sample in next, samples do
            local expected, cookie = unpack(sample)
            local w, req = writer.new(), request.new {
				method = 'POST',
				headers = {['cookie'] = 'l=' .. cookie}
			}
            app(w, req)
			assert.equals(400, w.status_code)
            assert.same({expected}, w.buffer)
        end
    end)
end

describe('demos.http.i18n-validation', function()
    test_cases(require 'demos.http.i18n-validation')
end)

describe('demos.web.i18n-validation', function()
    test_cases(require 'demos.web.i18n-validation')
end)
