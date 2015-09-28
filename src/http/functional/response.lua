local ResponseWriter = require('http.response')
_ENV = nil


local function new()
    return setmetatable({
        headers = {}
    }, {__index = ResponseWriter})
end

return {
    new = new
}
