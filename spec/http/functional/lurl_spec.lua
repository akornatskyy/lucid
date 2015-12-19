local lurl = require 'http.functional.lurl'
local describe, it, assert = describe, it, assert

describe('http.functional.lurl', function()
	it('shows usage', function()
        local saved = print
        local usage = nil
        _G['print'] = function(s)
            usage = s
        end
		lurl()
        _G['print'] = saved
        assert.not_nil(usage)
	end)

    it('calls app by path', function()
        local sarg = arg
        local sio = io
        local cases = {
            'demos/http/hello.lua',
            'demos.http.hello',
            'demos/web/hello.lua',
            'demos.http.hello'
        }
        for _, c in next, cases do
            local write_called = false
            _G['arg'] = {c, '/'}
            _G['io'] = {
                write = function(s)
                    write_called = true
                    assert.equals('Hello World!\n', s)
                end
            }
            lurl()
            assert(write_called)
        end
        _G['arg'] = sarg
        _G['io'] = sio
    end)
end)
