local stream = require 'http.adapters.nginx.stream'
local describe, it, assert = describe, it, assert

describe('http.adapters.nginx.stream', function()
	it('supports stream writer', function()
        local eof_called = false
        local ngx = {
            header = {},
            var = {
                request_method = 'GET',
                uri = '/'
            },
            print = function(c)
                assert.equals('Hello', c)
            end,
            eof = function()
                eof_called = true
            end
        }
        local app_called = false
		local app = function(w, req)
            app_called = true
            w:write('Hello')
            assert.same(ngx, w.ngx)
            assert.same(ngx.header, w.headers)
            assert.same(ngx, req.ngx)
            assert.equals('GET', req.method)
            assert.equals('/', req.path)
        end
        stream(app)(ngx)
        assert(app_called)
        assert(eof_called)
        assert.same({}, ngx.header)
	end)
end)
