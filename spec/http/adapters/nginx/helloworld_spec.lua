local helloworld = require 'http.adapters.nginx.helloworld'
local describe, it, assert = describe, it, assert

describe('http.adapters.nginx.helloworld', function()
	it('', function()
        local called = 0
        local ngx = {
            print = function(msg)
                called = called + 1
                assert.equals('Hello World!\n', msg)
            end,
            eof = function()
                called = called + 1
            end
        }
		helloworld(ngx)
        assert.equals(2, called)
	end)
end)
