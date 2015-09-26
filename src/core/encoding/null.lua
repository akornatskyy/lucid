_ENV = nil

local dummy = function(x)
    return x
end

return {
    encode = dummy,
    decode = dummy,
    encoded_len = dummy,
    decoded_len = dummy
}
