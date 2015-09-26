local json_encode

do
    local encoding = require 'core.encoding'
    json_encode = encoding.json.encode
end

local Mixin = {}


function Mixin:json(obj, status_code)
    if status_code then
        self:set_status_code(status_code)
    end
    self.headers['Content-Type'] = 'application/json'
    return self:write(json_encode(obj))
end

return Mixin
