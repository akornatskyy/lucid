local encode, decode

do
    for _, lib in next, {'cjson', 'json'} do
        local ok, l = pcall(require, lib)
        if ok then
            encode = l.encode
            decode = l.decode
            break
        else
            encode = function()
                error('json encode is not implemented')
            end
            decode = function()
                error('json decode is not implemented')
            end
        end
    end
end

return {
    encode = encode,
    decode = decode
}
