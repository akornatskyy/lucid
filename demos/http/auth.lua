local cipher = require 'security.crypto.cipher'
local digest = require 'security.crypto.digest'
local ticket = require 'security.crypto.ticket'

local http = require 'http'

local authorize = http.middleware.authorize
local authcookie = http.middleware.authcookie
local app = http.app.new {
    ticket = ticket.new {
        --digest = digest.new('sha256'),
        digest = digest.hmac('ripemd160', '6xZxzaP)C2d5LRnw'),
        cipher = cipher.new {
            cipher = 'aes128',
            key = 'DK((-x=e[.2cLq]f',
            iv = 'b#KXN>H9"j><f2N`'
        }
    },
    auth_cookie = {
        name = '_a'
    },
    principal = require 'security.principal'
}
app:use(http.middleware.routing)

--[[
    lurl -v demos/http/auth.lua /signin
--]]
app:get('signin', authcookie, function(w, req)
    w.principal = {id = 'john.smith', roles = {admin=true}}
end)

app:get('signout', authcookie, function(w, req)
    w.principal = nil
end)

--[[
    lurl -v -H 'Cookie: _a=' demos/http/auth.lua /secure
--]]
app:get('secure', authorize, function(w, req)
    if not req.principal.roles['admin'] then
        return w:set_status_code(403)
    end
    -- req.principal.id
end)

return app()
