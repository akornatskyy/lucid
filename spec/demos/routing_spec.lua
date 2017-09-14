local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local describe, it, assert = describe, it, assert

local function test_cases(app)
	assert.not_nil(app)

	it('responds with absolute url for user', function()
		local paths = {'/en/user/123', '/de/user/234'}
		for _, path in next, paths do
	        local w, req = writer.new(), request.new {path = path}
	        app(w, req)
	        assert.same({'http://localhost:8080' .. path .. '\n'}, w.buffer)
		end
	end)

	it('responds with not found if locale does not match', function()
        local w, req = writer.new(), request.new {path = '/ru/user/123'}
        app(w, req)
        assert.same(404, w.status_code)
	end)

	it('responds with not found', function()
        local w, req = writer.new(), request.new {path = '/unknown'}
        app(w, req)
        assert.same(404, w.status_code)
	end)

    describe('single path', function()
        it('mapped to http verb get', function()
            local w, req = writer.new(), request.new {
                path = '/api/users'
            }
            app(w, req)
            assert.same({req.path}, w.buffer)
        end)

        it('mapped to http verb post', function()
            local w, req = writer.new(), request.new {
                method = 'POST',
                path = '/api/users'
            }
            app(w, req)
            assert.same({'user added'}, w.buffer)
        end)
    end)
end

describe('demos.http.routing', function()
    local app = require 'demos.http.routing'
    test_cases(app)

	it('responds to any http verb', function()
        local http_verbs = {
            'DELETE', 'HEAD', 'OPTIONS', 'PATCH', 'POST', 'PUT', 'UNKNOWN'
        }
        for _, m in next, http_verbs do
            local w = writer.new()
            local req = request.new {method = m, path = '/all'}
            app(w, req)
            assert.same({'all'}, w.buffer)
        end
	end)
end)

describe('demos.web.routing', function()
    test_cases(require 'demos.web.routing')
end)
