local ok, l = pcall(require, 'cmsgpack')
if ok then
    return {
        encode = l.pack,
        decode = l.unpack
    }
end

ok, l = pcall(require, 'MessagePack')
if ok then
    return {
        encode = l.pack,
        decode = l.unpack
    }
end

return {
    encode = function()
        error('messagepack encode is not implemented')
    end,
    decode = function()
        error('messagepack decode is not implemented')
    end
}
