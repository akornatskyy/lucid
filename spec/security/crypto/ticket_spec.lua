local encoding = require 'core.encoding'
local cipher = require 'security.crypto.cipher'
local digest = require 'security.crypto.digest'

local ticket = require 'security.crypto.ticket'

describe('ticket', function()
    local t = ticket.new {
        --digest = digest.new('md5'),
        digest = digest.hmac('ripemd160', 'key1'),
        cipher = cipher.new('aes128', 'key2'),
        encoder = encoding.new('base64')
    }

    assert.equals(900, t.max_age)

    it('decrypt encrypted', function()
        local r = t:encode('test')
        local value = t:decode(r)
        assert.equals('test', value)
    end)

    describe('new', function()
        it('supports string for digest', function()
            assert(ticket.new {
                digest = 'md5',
                cipher = cipher.new('aes128', 'key2'),
                encoder = encoding.new('base64')
            })
        end)

        it('supports function for digest', function()
            local digest = require 'security.crypto.digest'
            local md5 = digest.new 'md5'
            assert(ticket.new {
                digest = md5,
                cipher = cipher.new('aes128', 'key2'),
                encoder = encoding.new('base64')
            })
        end)

        it('raises an error if digest is not a string or function', function()
            local f = function()
                ticket.new {}
            end
            assert.error(f, 'digest: string or function expected')
        end)

        it('supports max_age', function()
            assert.equals(60, ticket.new {
                digest = 'md5',
                max_age = 60,
                cipher = cipher.new('aes128', 'key2'),
                encoder = encoding.new('base64')
            }.max_age)
        end)
    end)

    describe('decode', function()
        it('unable to decode', function()
            local value, err = t:decode('$')
            assert.is_nil(value)
            assert.equals('unable to decode', err)
        end)

        it('signature mismatch', function()
            local value, err = t:decode('invalid')
            assert.is_nil(value)
            assert.equals('signature missmatch', err)
        end)

        it('unable to decrypt', function()
            local t2 = ticket.new {
                digest = digest.hmac('ripemd160', 'key1'),
                cipher = cipher.new('aes128', 'invalid'),
                encoder = encoding.new('base64')
            }
            local r = t:encode('test')
            local value, err = t2:decode(r)
            assert.is_nil(value)
            assert.equals('unable to decrypt', err)
        end)

        it('expired', function()
            local value, err = t:decode(
                'blRmix9ICePifLqLPHaVNkNV66IUdpn9Vy' ..
                'mIotdkoYFjb/UEqOl2ZGJTsPZ5P/kuWZ8NUw==')
            assert.is_nil(value)
            assert.equals('expired', err)
        end)
    end)
end)
