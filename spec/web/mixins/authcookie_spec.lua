local authcookie = require 'web.mixins.authcookie'
local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local describe, it, assert = describe, it, assert

describe('web.mixins.authcookie', function()
	it('extends time left', function()
		local c = setmetatable({
            req = request.new {
				headers = {
					cookie = '_a=cookie'
				},
                options = {
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
            },
            w = writer.new()
        }, {__index=authcookie})
        local p, time_left = c:parse_auth_cookie()
        assert.equals('1', p)
        assert.equals(5, time_left)
        assert.equals('_a=2; HttpOnly', c.w.headers['Set-Cookie'])
	end)
end)
