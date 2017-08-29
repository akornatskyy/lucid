local type, error = type, error
local new

local Cipher = {}
local mt = {__index = Cipher}

do
    local ok, l = pcall(require, 'openssl.cipher')
    if ok then
        local make = l.new

        function Cipher:encrypt(s)
            return make(self.cipher):encrypt(self.key, self.iv):final(s)
        end

        function Cipher:decrypt(s)
            return make(self.cipher):decrypt(self.key, self.iv):final(s)
        end

        new = function(self)
            if type(self.cipher) ~= 'string' then
                error('cipher: string expected', 2)
            end
            if type(self.key) ~= 'string' then
                error('key: string expected', 2)
            end
            if self.iv and type(self.iv) ~= 'string' then
                error('iv: string or nil expected', 2)
            end
            return setmetatable(self, mt)
        end
    else
        new = function()
            error('openssl cipher is not available')
        end
    end
end

return {
    new = new
}
