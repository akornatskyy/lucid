local ok, l = pcall(require, 'cjson')
if ok then
    return {
        encode = l.encode,
        decode = l.decode
    }
end

ok, l = pcall(require, 'json')
if ok then
    return {
        encode = l.encode,
        decode = l.decode
    }
end

return {
    encode = function()
        error('json encode is not implemented')
    end,
    decode = function()
        error('json decode is not implemented')
    end
}
