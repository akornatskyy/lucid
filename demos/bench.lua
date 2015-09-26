package.path = package.path .. ';demos/?.lua'

local Request = require('http.request')
local ResponseWriter = require('http.response')
local app = require(arg[1] or 'test')

local w = setmetatable({
    headers = {}
}, {__index = ResponseWriter})

local req = setmetatable({
    method = 'POST',
    path = '/',
    form = {author='John', message='Hello World!'},
    server_parts = function()
        return 'http', 'localhost', '8080'
    end
}, {__index = Request})

app(w, req)
--for i = 1, 1000000 do for j = 1, 1 do app(w, req) end end
