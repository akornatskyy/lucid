local json_encode

do
    local encoding = require 'core.encoding'
    json_encode = encoding.json.encode
end

local Mixin = {}


function Mixin:json(obj)
    self.headers['Content-Type'] = 'application/json'
    return self:write(json_encode(obj))
end

return Mixin
