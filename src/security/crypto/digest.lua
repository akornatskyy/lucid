local type, error = type, error
local new, hmac

do
    local ok = pcall(require, 'openssl')
    if ok then
        local d = require('openssl.digest').new
        new = function(digest_type)
            if type(digest_type) ~= 'string' then
                error('string expected', 2)
            end

            return function(s)
                return d(digest_type):final(s)
            end
        end
        local h = require('openssl.hmac').new
        hmac = function(digest_type, key)
            if type(digest_type) ~= 'string' then
                error('digest: string expected', 2)
            end
            if type(key) ~= 'string' then
                error('key: string expected', 2)
            end
            return function(s)
                return h(key, digest_type):final(s)
            end
        end
    else
        new = function()
            error('openssl digest is not available', 2)
        end
        hmac = function()
            error('openssl hmac is not available', 2)
        end
    end
end

return {
    new = new,
    hmac = hmac
}
