local struct = require 'struct'
local rand = require 'security.crypto.rand'
local pack, unpack, rand_bytes = struct.pack, struct.unpack, rand.bytes
local assert, type, time = assert, type, os.time
local setmetatable = setmetatable


local Ticket = {
    encode = function(self, s)
        local b = rand_bytes(12)
        s = self.cipher:encrypt(
            b:sub(1, 4) ..
            pack('<I4', time() + self.max_age) ..
            b:sub(5, 8) ..
            s ..
            b:sub(9, 12))
        return self.encoder.encode(self.digest(s) .. s)
    end,

    decode = function(self, s)
        s = self.encoder.decode(s)
        if not s then
            return nil, 'unable to decode'
        end
        local t = s:sub(1, self.digest_size)
        s = s:sub(1 + self.digest_size)
        if t ~= self.digest(s) then
            return nil, 'signature missmatch'
        end
        s = self.cipher:decrypt(s)
        if not s then
            return nil, 'unable to decrypt'
        end
        t = unpack('<I4', s:sub(5, 8)) - time()
        if t < 0 or t > self.max_age then
            return nil, 'expired'
        end
        return s:sub(13, -5), t
    end
}

local mt = {__index = Ticket}

local new = function(self)
    if type(self.digest) == 'string' then
        local d = require 'security.crypto.digest'
        self.digest = d.new(self.digest)
    elseif type(self.digest) ~= 'function' then
        error('digest: string or function expected', 2)
    end
    if not self.encoder then
        self.encoder = require('core.encoding').new('base64')
    end
    assert(self.cipher)
    assert(self.cipher.encrypt)
    assert(self.cipher.decrypt)
    assert(self.encoder)
    assert(self.encoder.encode)
    assert(self.encoder.decode)
    if not self.max_age then
        self.max_age = 900
    end
    self.digest_size = self.digest(''):len()
    return setmetatable(self, mt)
end

return {
    new = new
}
