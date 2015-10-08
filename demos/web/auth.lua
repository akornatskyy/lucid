local class = require 'core.class'
local encoding = require 'core.encoding'
local mixin = require 'core.mixin'
local cipher = require 'security.crypto.cipher'
local digest = require 'security.crypto.digest'
local principal = require 'security.principal'
local ticket = require 'security.crypto.ticket'
local http = require 'http'
local web = require 'web'


local BaseHandler = mixin(
    {},
    web.mixins.AuthCookieMixin,
    web.mixins.PrincipalMixin
)

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
    principal = principal,
    auth_cookie = {
        name = '_a', path = '/',
        deleted = http.cookie.delete {name = '_a', path = '/'}
    },
    ticket = ticket.new {
        --digest = digest.new('md5'),
        digest = digest.hmac('ripemd160', 'key1'),
        cipher = cipher.new('aes256', 'key2'),
        encoder = encoding.new('base64')
    }
}

return web.app({web.middleware.routing}, options)
