local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local describe, it, assert = describe, it, assert

local function test_cases(app)
    assert.not_nil(app)

    local http_verbs = {
        'GET', 'HEAD', 'POST', 'PUT', 'DELETE'
    }
    for _, m in next, http_verbs do
        it('no special headers if no origin for HTTP ' .. m, function()
            local w, req = writer.new(), request.new {
                method = m
            }
            app(w, req)
            assert.is_nil(w.status_code)
            assert.same({}, w.headers)
        end)

        it('responds to pre-flight request ' .. m, function()
            local w, req = writer.new(), request.new {
                method = 'OPTIONS',
                headers = {
                    ['origin'] = 'http://web.local',
                    ['access-control-request-method'] = m,
                    ['access-control-request-headers'] = 'x-requested-with'
                }
            }
            app(w, req)
            assert.equals(204, w.status_code)
            assert.same({
                ['Access-Control-Allow-Credentials'] = 'true',
                ['Access-Control-Allow-Headers'] = 'x-requested-with',
                ['Access-Control-Allow-Methods'] = 'GET,HEAD,POST,PUT,DELETE',
                ['Access-Control-Allow-Origin'] = 'http://web.local',
                ['Access-Control-Max-Age'] = '180',
                ['Vary'] = 'Origin'
            }, w.headers)
        end)

        it('responds with CORS headers for method ' .. m, function()
            local w, req = writer.new(), request.new {
                method = m,
                headers = {origin = 'http://web.local'}
            }
            app(w, req)
            assert.is_nil(w.status_code)
            assert.same({
                ['Access-Control-Allow-Credentials'] = 'true',
                ['Access-Control-Allow-Origin'] = 'http://web.local',
                ['Access-Control-Expose-Headers'] = 'content-length,etag',
                ['Vary'] = 'Origin'
            }, w.headers)
        end)
    end
end

describe('demos.http.cors', function()
    test_cases(require 'demos.http.cors')
end)

describe('demos.web.cors', function()
    test_cases(require 'demos.web.cors')
end)
