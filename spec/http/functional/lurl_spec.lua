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
end)
