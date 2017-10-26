local type, error = type, error
local bytes, uniform

do
    local ok, l = pcall(require, 'openssl.rand')
    if ok then
        bytes = l.bytes
        uniform = l.uniform
    else
        bytes = function()
            error('openssl rand bytes is not available')
        end

        uniform = function()
            error('openssl rand uniform is not available')
        end
    end
end

return {
    bytes = bytes,
    uniform = uniform
}
