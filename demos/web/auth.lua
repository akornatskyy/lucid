local class = require 'core.class'
local mixin = require 'core.mixin'
local cipher = require 'security.crypto.cipher'
local digest = require 'security.crypto.digest'
local ticket = require 'security.crypto.ticket'
local web = require 'web'


local BaseHandler = mixin({}, web.mixins.authcookie, web.mixins.principal)

--[[
    lurl -v demos/web/auth.lua /signin
--]]
local SignInHandler = class(BaseHandler, {
    get = function(self)
        self:set_principal {
            id = 'john.smith',
            roles = {admin=true}
        }
    end
})

local SignOutHandler = class(BaseHandler, {
    get = function(self)
        self:set_principal()
    end
})

--[[
    lurl -v -H 'Cookie: _a=' demos/web/auth.lua /secure
--]]
local SecureHandler = class(BaseHandler, {
    get = function(self)
        if not self:get_principal() then
            return self.w:set_status_code(401)
        end
    end
})

-- url mapping

local all_urls = {
    {'signin', SignInHandler},
    {'signout', SignOutHandler},
    {'secure', SecureHandler}
}

-- config

local options = {
    urls = all_urls,
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

return web.app({web.middleware.routing}, options)
