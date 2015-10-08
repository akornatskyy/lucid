local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local describe, it, assert = describe, it, assert

local function signin(app)
    local w, req = writer.new(), request.new {path = '/signin'}
    app(w, req)
    local c = w.headers['Set-Cookie']
    assert(c)
    c = c:match('^(_a=.-);')
    return c
end

local function secure(app)
    local c = signin(app)
    local w = writer.new()
    local req = request.new {
        path = '/secure',
        headers = {cookie = c}
    }
    app(w, req)
    return w, req
end

local function test_cases(app)
	assert.not_nil(app)

	it('responds with auth cookie', function()
        local c = signin(app)
        assert.not_nil(c)
	end)

	it('responds with unauthorized status code', function()
        local w, req = writer.new(), request.new {path = '/secure'}
        app(w, req)
        assert.equals(401, w.status_code)

        w = writer.new()
        req = request.new {
            path = '/secure',
            cookies = {_a = 'x'}
        }
        app(w, req)
        assert.equals(401, w.status_code)
    end)

	it('parses auth cookie', function()
        local w = secure(app)
        assert.is_nil(w.status_code)
	end)

	it('removes auth cookie', function()
        local c = signin(app)
        assert.not_nil(c)
        local w = writer.new()
        local req = request.new {
            path = '/signout',
            headers = {cookie = c}
        }
        app(w, req)
        assert.is_nil(w.status_code)
        assert.equals('_a=; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Path=/',
                      w.headers['Set-Cookie'])
	end)
end

describe('demos.http.auth', function()
    local app = require 'demos.http.auth'
    test_cases(app)

    it('adds parsed security principal to request', function()
        local w, req = secure(app)
        assert.is_nil(w.status_code)
        assert.same({
            id = 'john.smith',
            roles = {admin = true},
            alias = '',
            extra = ''
        }, req.principal)
    end)
end)

describe('demos.web.auth', function()
    local app = require 'demos.web.auth'
    test_cases(app)
end)
