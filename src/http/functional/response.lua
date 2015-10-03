local mixin = require 'core.mixin'
local ResponseWriter = require('http.response')


mixin(ResponseWriter, {
    get_status_code = function(self)
        return self.status_code
    end,

    set_status_code = function(self, code)
        self.status_code = code
    end,

    write = function(self, c)
        self.buffer[#self.buffer+1] = c
    end
})


local function new()
    return setmetatable({headers={}, buffer={}}, {__index = ResponseWriter})
end

return {
    new = new
}
