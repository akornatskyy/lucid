local messagepack = require 'core.encoding.messagepack'
local describe, it, assert = describe, it, assert

describe('core.encoding.messagepack', function()
    it('encode decode', function()
        local t = {x = 1}
        assert.same(t, messagepack.decode(messagepack.encode(t)))
    end)

    it('encode empty table as array', function()
        assert.equals('\144', messagepack.encode({}))
    end)

    describe('not implemented', function()
        it('raises an error', function()
            local saved = require
            _G['require'] = function(m)
                if m == 'cmsgpack' or m == 'MessagePack' then
                    return error()
                end
                return saved(m)
            end
            package.loaded['cmsgpack'] = nil
            package.loaded['core.encoding.messagepack'] = nil
            local j = require 'core.encoding.messagepack'
            assert.error(j.encode, 'messagepack encode is not implemented')
            assert.error(j.decode, 'messagepack decode is not implemented')
            package.loaded['core.encoding.messagepack'] = nil
            _G['require'] = saved
        end)
    end)
end)
