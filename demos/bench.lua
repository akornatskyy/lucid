--[[
export LUA_CPATH='./env/lib/lua/5.1/?.so'
export LUA_PATH='./demos/?.lua;./src/?.lua;./env/share/lua/5.1/?.lua;./env/share/lua/5.1/?/init.lua'
time ../other/luajit-2.0/src/luajit demos/bench.lua
--]]

local Request = require('http.request')
local ResponseWriter = require('http.response')
local app = require(arg[1] or 'hello')

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
