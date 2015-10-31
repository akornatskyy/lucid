local mixin = require 'core.mixin'
local ResponseWriter = require 'http.response'
local setmetatable = setmetatable
local mt = {__index = ResponseWriter}


mixin(ResponseWriter, {
    get_status_code = function(self)
        return self.status_code
    end,

    set_status_code = function(self, code)
        self.status_code = code
    end,

    write = function(self, c)
        local b = self.buffer
        b[#b+1] = c
    end
})

local function new()
    return setmetatable({headers={}, buffer={}}, mt)
end

return {
    new = new
}
