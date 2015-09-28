package.path = package.path .. ';demos/?.lua'

local clockit = require 'core.clockit'
local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local app = require(arg[1] or 'test')

local w = writer.new()
local req = request.new({
    --method = 'POST'
})


clockit.ptimes(function()
    app(w, req)
end)
