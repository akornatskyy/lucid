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

    it('path with query string', function()
        local sarg = arg
        local sio = io
        _G['arg'] = {'demos.http.api', '/api/v1/tasks?status=1'}
        _G['io'] = {write = function(s) end}
        lurl()
        _G['arg'] = sarg
        _G['io'] = sio
    end)

    it('-X option', function()
        local sarg = arg
        local sio = io
        local c = ''
        _G['arg'] = {'-X', 'POST', 'demos.http.api', '/api/v1/tasks'}
        _G['io'] = {write = function(s) c = s end}
        lurl()
        assert.equals('{"title":"Required field cannot be left blank."}', c)
        _G['arg'] = sarg
        _G['io'] = sio
    end)

    it('-H option', function()
        local sarg = arg
        local sio = io
        _G['arg'] = {'-H', 'Cookie: _a=', 'demos.http.auth', '/signout'}
        _G['io'] = {write = function(s) end}
        lurl()
        _G['arg'] = sarg
        _G['io'] = sio
    end)

    it('-d option', function()
        local sarg = arg
        local sio = io
        local c = ''
        _G['arg'] = {'-d', '{"author":"Jack"}', 'demos.http.form', '/'}
        _G['io'] = {write = function(s) c = s end}
        lurl()
        assert.equals('{"message":"Required field cannot be left blank."}', c)
        _G['arg'] = sarg
        _G['io'] = sio
    end)
end)
