local encoding = require 'core.encoding'

local cipher = require 'security.crypto.cipher'
local digest = require 'security.crypto.digest'
local ticket = require 'security.crypto.ticket'

local http = require 'http'

local authorize = http.middleware.authorize
local authcookie = http.middleware.authcookie
local app = http.app.new {
    ticket = ticket.new {
        digest = digest.hmac('ripemd160', 'key1'),
        cipher = cipher.new('aes256', 'key2'),
        encoder = encoding.new('base64')
    }
}
app:use(http.middleware.routing)

--[[
    lurl -v demos/http/auth.lua /signin
--]]
app:get('signin', authcookie, function(w, req)
    w.principal = {id = 'john.smith', roles = {admin=true}}
end)

--[[
    lurl -v -H 'Cookie: _a=' demos/http/auth.lua /secure
--]]
app:get('secure', authorize, function(w, req)
    return w:write('Hello World!\n')
end)

return app()
