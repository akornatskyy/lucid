local encoding = require 'core.encoding'
local cipher = require 'security.crypto.cipher'
local digest = require 'security.crypto.digest'

local ticket = require 'security.crypto.ticket'

describe('ticket', function()
    it('', function()
        local t = ticket.new {
            --digest = digest.new('md5'),
            digest = digest.hmac('ripemd160', 'key1'),
            cipher = cipher.new('aes128', 'key2'),
            encoder = encoding.new('base64')
        }
        local r = t:encode('test')
        local value = t:decode(r)
        assert.equals('test', value)
    end)
end)
