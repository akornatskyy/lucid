local class = require 'core.class'
local http = require 'http'
local web = require 'web'


local function hello(self)
    self.w:write('Hello World!\n')
end

--[[
    lurl -v demos.web.cors /
    curl -v http://localhost:8080
--]]
local WelcomeHandler = class {
    get = hello,
    head = hello,
    post = hello,
    put = hello,
    delete = hello
}

-- url mapping

local all_urls = {
    {'', WelcomeHandler}
}

-- config

local options = {
    urls = all_urls,
    cors = http.cors.new {
        allow_credentials = true,
        allowed_origins = {'*'},
        allowed_methods = {'GET', 'HEAD', 'POST', 'PUT', 'DELETE'},
        allowed_headers = {'content-type', 'x-requested-with'},
        exposed_headers = {'content-length', 'etag'},
        max_age = 180
    }
}

return web.app({http.middleware.cors, web.middleware.routing}, options)
