local digest = require 'security.crypto.digest'
local encoding = require 'core.encoding'
local describe, it, assert, next = describe, it, assert, next

describe('security.crypto.digest', function()
    describe('new', function()
        it('raises an error if not string', function()
            assert.error(digest.new, 'string expected')
        end)

        local b64 = encoding.new 'base64'
        local cases = {
            sha1 = 'qUqP5cyxm6YcTAhz05Hph5gvu9M=',
            ripemd160 = 'XlL+5H5rBwVl90NyRozcaZ3okQc=',
            sha224 = 'kKPtnjKyqvTGHEEOuSVCYRnhqdxT1Chq3pmoCQ==',
            sha256 = 'n4bQgYhMfWWaL+qgxVrQFaO/TxsrC4Is0V1sFbDwCgg=',
            sha384 = 'doQSMg97CqWBL85CjcRwazyuUOAqZMqhangiSb/o78S37' ..
                     'xzLEmJV0ZYEff7fF6Cp',
            sha512 = '7iaw3Ur350mqGo7jwQrpkj9hiYB3Lkc/iBml1JQODbJ6w' ..
                     'YX4oOHV+E+IvIh/1nsUNzLDBMxfqa2Ob1f1ACio/w==',
            md4 = '2zRtaR16zE3CYl2xn54/Ug==',
            md5 = 'CY9rzUYh03PK3k6DJie09g=='
        }
        for digest_type, expected in next, cases do
            it('supports ' .. digest_type, function()
                local d = digest.new(digest_type)
                assert.equals(expected, b64.encode(d('test')))
            end)
        end
    end)

    describe('hmac', function()
        it('raises an error if digest type is not string', function()
            assert.error(digest.hmac, 'digest: string expected')
        end)

        it('raises an error if key is not string', function()
            local f = function()
                return digest.hmac 'md5'
            end
            assert.error(f, 'key: string expected')
        end)

        local b64 = encoding.new 'base64'
        local cases = {
            sha1 = 'qUqP5cyxm6YcTAhz05Hph5gvu9M=',
            ripemd160 = 'XlL+5H5rBwVl90NyRozcaZ3okQc=',
            sha224 = 'kKPtnjKyqvTGHEEOuSVCYRnhqdxT1Chq3pmoCQ==',
            sha256 = 'n4bQgYhMfWWaL+qgxVrQFaO/TxsrC4Is0V1sFbDwCgg=',
            sha384 = 'doQSMg97CqWBL85CjcRwazyuUOAqZMqhangiSb/o78S37xzLE' ..
                     'mJV0ZYEff7fF6Cp',
            sha512 = '7iaw3Ur350mqGo7jwQrpkj9hiYB3Lkc/iBml1JQODbJ6wYX4o' ..
                     'OHV+E+IvIh/1nsUNzLDBMxfqa2Ob1f1ACio/w==',
            md4 = '2zRtaR16zE3CYl2xn54/Ug==',
            md5 = 'CY9rzUYh03PK3k6DJie09g=='
        }
        for digest_type, expected in next, cases do
            it('supports ' .. digest_type, function()
                local d = digest.new(digest_type)
                assert.equals(expected, b64.encode(d('test')))
            end)
        end
    end)
end)
