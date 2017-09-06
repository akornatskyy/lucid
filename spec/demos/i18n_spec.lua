local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local describe, it, assert = describe, it, assert

local function test_cases(app)
	assert.not_nil(app)

	it('responds with hello', function()
        local w, req = writer.new(), request.new()
        app(w, req)
        assert.same({'Hello!\n'}, w.buffer)
	end)

    it('responds with days', function()
		local samples = {
            {'0 days', '/en/days/0'},
            {'1 day', '/en/days/1'},
            {'2 days', '/en/days/2'},
            {'1 день', '/uk/days/1'},
            {'2 дні', '/uk/days/2'},
            {'5 днів', '/uk/days/5'}
        }
        for _, sample in next, samples do
            local expected, path = unpack(sample)
            local w, req = writer.new(), request.new {path = path}
            app(w, req)
            assert.same({expected}, w.buffer)
        end
    end)
end

describe('demos.http.i18n', function()
    test_cases(require 'demos.http.i18n')
end)

describe('demos.web.i18n', function()
    test_cases(require 'demos.web.i18n')
end)
