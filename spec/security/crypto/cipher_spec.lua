local cipher = require 'security.crypto.cipher'
local encoding = require 'core.encoding'
local describe, it, assert, next = describe, it, assert, next

describe('security.crypto.cipher', function()
    describe('new', function()
        it('raises an error if no arguments passed', function()
            assert.error(cipher.new)
        end)

        it('raises an error if cipher type is not string', function()
            local f = function()
                return cipher.new {}
            end
            assert.error(f, 'cipher: string expected')
        end)

        it('raises an error if key is not string', function()
            local f = function()
                return cipher.new {
                    cipher = 'RC2'
                }
            end
            assert.error(f, 'key: string expected')
        end)

        it('raises an error if iv is not string', function()
            local f = function()
                return cipher.new {
                    cipher = 'RC2',
                    key = '',
                    iv = 1
                }
            end
            assert.error(f, 'iv: string or nil expected')
        end)

        it('iv is optional', function()
            cipher.new {
                cipher = 'RC2',
                key = ''
            }
        end)

        local b64 = encoding.new('base64')
        local cases = {
            {'DES', 8, 8, '3WC8O0rbWao='},
            {'RC4', 16, 0, 'cMtFbA=='},
            {'RC2', 16, 8, 'A5VQhbRW4wc='},
            {'SEED', 16, 16, 'WCuKWOd3hpKP7cLTTBaWww=='},
            {'AES128', 16, 16, 'Wf3+EizbV+i8nwRvZqBNAQ=='},
            {'AES192', 24, 16, '3oaMbtA2fTJKyDPkGnC3EQ=='},
            {'AES256', 32, 16, '481gVqrumY50mOZE+QfTQA=='}
        }
        for _, c in next, cases do
            local cipher_type, expected = c[1], c[4]
            it('supports ' .. cipher_type, function()
                local ciph = cipher.new {
                  cipher = cipher_type,
                  key = string.rep('x', c[2]),
                  iv = string.rep('x', c[3])
                }
                assert.equals(expected, b64.encode(ciph:encrypt('test')))
                assert.equals('test', ciph:decrypt(b64.decode(expected)))
	        end)
        end
    end)
end)
