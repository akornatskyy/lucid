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
            local headers = {x=1}
            local req = setmetatable({ngx = {
                req = {
                    get_headers = function()
                        return headers
                    end
                }
            }}, {__index=base.Request})
            assert.same(headers, req:parse_headers())
            assert.same(headers, req.headers)
        end)

        it('parse headers', function()
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

        it('parse body', function()
            local read_body_called = false
            local body = {x=1}
            local req = setmetatable({ngx = {
                req = {
                    read_body = function()
                        read_body_called = true
                    end,
                    get_headers = function()
                        return {}
                    end,
                    get_post_args = function()
                        return body
                    end
                }
            }}, {__index=base.Request})
            assert.same(body, req:parse_body())
            assert.same(body, req.body)
            assert(read_body_called)
        end)

        it('parse body currupted json', function()
            local read_body_called = false
            local get_body_data_called = false
            local req = setmetatable({ngx = {
                req = {
                    read_body = function()
                        read_body_called = true
                    end,
                    get_headers = function()
                        return {['content-type'] = 'application/json'}
                    end,
                    get_body_data = function()
                        get_body_data_called = true
                        return ''
                    end
                }
            }}, {__index=base.Request})
            assert.is_nil(req:parse_body())
            assert(read_body_called)
            assert(get_body_data_called)
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
