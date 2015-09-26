local type, error = type, error
_ENV = nil

local new, hmac

do
    local ok, l = pcall(require, 'crypto')
    if ok then
        local d, h = l.digest, l.hmac.digest
        new = function(dtype)
            if type(dtype) ~= 'string' then
                error('string expected', 2)
            end
            return function(s)
                return d(dtype, s, true)
            end
        end
        hmac = function(dtype, key)
            if type(dtype) ~= 'string' then
                error('digest: string expected', 2)
            end
            if type(key) ~= 'string' then
                error('key: string expected', 2)
            end
            return function(s)
                return h(dtype, s, key, true)
            end
        end
    end
end

return {
    new = new,
    hmac = hmac
}
