local encode, decode

do
    local ok, l = pcall(require, 'base64')
    if ok then
        encode = l.encode
        decode = l.decode
    else
        encode = function()
            error('base64 encode is not implemented')
        end
        decode = function()
            error('base64 decode is not implemented')
        end
    end
end

local encoded_len = function(n)
    return math.flor((n + 2) / 3) * 4
end

local decoded_len = function(n)
    return math.flor(n / 4) * 3
end

return {
    encode = encode,
    decode = decode,
    encoded_len = encoded_len,
    decoded_len = decoded_len
}

