local b64 = require 'core.encoding.base64'
local describe, it, assert = describe, it, assert
_ENV = nil

describe('base64', function()
    it('RFC 3548', function()
        local cases = {
            ['FPucA9l+'] = '\20\251\156\3\217\126',
            ['FPucA9k='] = '\20\251\156\3\217',
            ['FPucAw=='] = '\20\251\156\3'
        }
        for e, c in next, cases do
            assert.equals(e, b64.encode(c))
            assert.equals(c, b64.decode(e))
        end
    end)

    it('RFC 4648', function()
        local cases = {
            [''] = '',
            ['Zg=='] = 'f',
            ['Zm8='] = 'fo',
            ['Zm9v'] = 'foo',
            ['Zm9vYg=='] = 'foob',
            ['Zm9vYmE='] = 'fooba',
            ['Zm9vYmFy'] = 'foobar'
        }
        for e, c in next, cases do
            assert.equals(e, b64.encode(c))
            assert.equals(c, b64.decode(e))
        end
    end)

    describe('decode', function()
        it('corrupted', function()
            local cases = {
                {'', '===='},
                {'', 'x==='},
                {'', 'A==='},
                {'', 'A=AA'},
                {'', 'A=AA'},
                {'\0', 'AA=A'},
                {'\0', 'AA==A'},
                {'\0\0', 'AAA=AAAA'},
                {'\0\0\0', 'AAAAA'},
                {'\0\0\0', 'AAAAAA'},
                {'', 'A='},
                {'', 'A=='},
                {'\0', 'AA='},
                {'\0', 'AA=='},
                {'\0\0', 'AAA='},
                {'\0\0\0', 'AAAA'},
                {'\0\0\0\0', 'AAAAAA='},
                {'abcd', 'YWJjZA====='}
            }
            for _, c in next, cases do
                local e, s = c[1], c[2]
                assert.equals(e, b64.decode(s))
            end
            assert.is_nil(b64.decode('!!!!'))
        end)

        it('ignores new line characters', function()
            local cases = {
                'c3VyZQ==',
                'c3VyZQ==\r',
                'c3VyZQ==\n',
                'c3VyZQ==\r\n',
                'c3VyZ\r\nQ==',
                'c3V\ryZ\nQ==',
                'c3V\nyZ\rQ==',
                'c3VyZ\nQ==',
                'c3VyZQ\n==',
                'c3VyZQ=\n=',
                'c3VyZQ=\r\n\r\n=',
            }
            for _, c in next, cases do
                assert.equals('sure', b64.decode(c))
            end
        end)
    end)
end)
