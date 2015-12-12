local base = require 'http.adapters.nginx.base'
local describe, it, assert = describe, it, assert

describe('http.adapters.nginx.base', function()
    describe('response writer', function()
        it('get or set status code', function()
            local w = setmetatable({ngx={}}, {__index=base.ResponseWriter})
            assert.is_nil(w:get_status_code())
            w:set_status_code(403)
            assert.equals(403, w:get_status_code())
        end)

        it('flushes', function()
            local flush_called = false
            local w = setmetatable({ngx = {
                flush = function()
                    flush_called = true
                end
            }}, {__index=base.ResponseWriter})
            w:flush()
            assert(flush_called)
        end)
    end)

    describe('request', function()
        it('parse query', function()
            local query = {x=1}
            local req = setmetatable({ngx = {
                req = {
                    get_uri_args = function()
                        return query
                    end
                }
            }}, {__index=base.Request})
            assert.same(query, req:parse_query())
            assert.same(query, req.query)
        end)

        it('server parts', function()
            local req = setmetatable({ngx = {
                var = {
                    scheme = 'http',
                    host = 'localhost',
                    server_port = 8080
                }
            }}, {__index=base.Request})
            local scheme, host, server_port = req:server_parts()
            assert.equals('http', scheme)
            assert.equals('localhost', host)
            assert.equals(8080, server_port)
        end)
    end)
end)
