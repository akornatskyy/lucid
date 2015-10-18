local assert = assert
local json_encode

do
    local encoding = require 'core.encoding'
    json_encode = encoding.json.encode
end

local Mixin = {}

function Mixin:json(obj)
    self.w.headers['Content-Type'] = 'application/json'
    return self.w:write(json_encode(obj))
end

function Mixin:json_errors()
    assert(self.errors)
    self.w:set_status_code(400)
    self.w.headers['Content-Type'] = 'application/json'
    return self.w:write(json_encode(self.errors))
end

return Mixin
