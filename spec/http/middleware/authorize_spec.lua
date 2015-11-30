local authorize = require 'http.middleware.authorize'
local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local describe, it, assert = describe, it, assert

describe('http.middleware.authorize', function()
	it('extends time left', function()
        local options = {
            auth_cookie = {name = '_a'},
            ticket = {
                max_age = 15,
                decode = function(self, c)
                    assert.equals('cookie', c)
                    return '1', 5
                end,
                encode = function(self, p)
                    assert.equals('1', p)
                    return '2'
                end
            }
        }

        local app = authorize(function() end, options)
        local w = writer.new()
        local req = request.new {
            get_cookie = function()
                return 'cookie'
            end
        }
        app(w, req)
        assert.equals('_a=2; Path=/; HttpOnly', w.headers['Set-Cookie'])
	end)
end)
