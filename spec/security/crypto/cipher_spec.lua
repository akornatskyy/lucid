local cipher = require 'security.crypto.cipher'
local encoding = require 'core.encoding'
local describe, it, assert, next = describe, it, assert, next

describe('security.crypto.cipher', function()
    describe('new', function()
        it('raises an error if cipher type is not string', function()
            assert.error(cipher.new, 'cipher: string expected')
        end)

        it('raises an error if key is not string', function()
            local f = function()
                return cipher.new 'RC2'
            end
            assert.error(f, 'key: string expected')
        end)

        local b64 = encoding.new('base64')
        local cases = {
            DES = 'HeLF6CpPBKY=',
            RC4 = 'ZkiPqg==',
            RC2 = 'JWyXGjIr5Zw=',
            SEED = 'cDmFVxqoU8AemFDNeINdCA==',
            AES128 = 'npzkTNnfKyAfUZR+A7zL4g==',
            AES192 = 'k35bgjlTQSq6KldRevLegw==',
            AES256 = '+fEk0DfN491ECEqRidcnoA=='
        }
        for cipher_type, expected in next, cases do
            it('supports ' .. cipher_type, function()
                local c = cipher.new(cipher_type, 'key')
                assert.equals(expected, b64.encode(c.encrypt('test')))
                assert.equals('test', c.decrypt(b64.decode(expected)))
	        end)
        end
	end)
end)
