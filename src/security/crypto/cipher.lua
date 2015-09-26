local type, error = type, error
_ENV = nil

local new

do
    local ok, l = pcall(require, 'crypto')
    if ok then
        local e, d = l.encrypt, l.decrypt
        new = function(cipher, key)
            if type(cipher) ~= 'string' then
                error('cipher: string expected', 2)
            end
            if type(key) ~= 'string' then
                error('key: string expected', 2)
            end
            return {
                encrypt = function(s)
                    return e(cipher, s, key)
                end,
                decrypt = function(s)
                    return d(cipher, s, key)
                end
            }
        end
    end
end

return {
    new = new
}
