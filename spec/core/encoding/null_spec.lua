local null = require 'core.encoding.null'
local describe, it, assert = describe, it, assert

describe('core.encoding.null', function()
	it('no op', function()
		assert.equals('x', null.encode('x'))
		assert.equals('x', null.decode('x'))
		assert.equals(1, null.encoded_len(1))
		assert.equals(1, null.decoded_len(1))
	end)
end)
