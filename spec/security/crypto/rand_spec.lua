local rand = require 'security.crypto.rand'

describe('rand', function()
    describe('bytes', function()
        it('generates random byte string of specified length', function()
            local cases = {1, 2, 4, 8, 16, 32, 100, 1024}
            for _, c in next, cases do
                local r = rand.bytes(c)
                assert.equals(c, r:len())
            end
        end)
    end)

    describe('uniform', function()
        it('generates random intger of specified range', function()
            local cases = {2, 16, 1024, 0xFFFF, 0xFFFFFFFF}
            for _, n in next, cases do
                local r = rand.uniform(n)
                assert(r >= 0 and r < n)
            end
        end)
    end)
end)
