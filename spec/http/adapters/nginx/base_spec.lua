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
end)
