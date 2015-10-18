local struct = require 'struct'
local pack, unpack = struct.pack, struct.unpack
local assert, type, random, time = assert, type, math.random, os.time
local setmetatable = setmetatable


local Ticket = {
    encode = function(self, s)
        s = self.cipher.encrypt(
            pack('<I4I4I4',
                 random(-0x80000000, 0x7FFFFFFF),
                 time() + self.max_age,
                 random(-0x80000000, 0x7FFFFFFF)
            ) ..
            s .. pack('<I4', random(-0x80000000, 0x7FFFFFFF))
        )
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
        s = self.cipher.decrypt(s)
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
