local encode, decode

do
    for _, lib in next, {'MessagePack'} do
        local ok, l = pcall(require, lib)
        if ok then
            encode = l.pack
            decode = l.unpack
            break
        else
            encode = function()
                error('messagepack encode is not implemented')
            end
            decode = function()
                error('messagepack decode is not implemented')
            end
        end
    end
end

return {
    encode = encode,
    decode = decode
}

