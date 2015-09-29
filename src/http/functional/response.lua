local ResponseWriter = require('http.response')


local function new(self)
    if not self then
        self = {}
    end
    self.headers = {}
    return setmetatable(self, {__index = ResponseWriter})
end

return {
    new = new
}
