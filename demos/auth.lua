local class = require 'core.class'
local encoding = require 'core.encoding'
local mixin = require 'core.mixin'
local cipher = require 'security.crypto.cipher'
local digest = require 'security.crypto.digest'
local principal = require 'security.principal'
local ticket = require 'security.crypto.ticket'
local http = require 'http'
local web = require 'web'

--_ENV = nil

local BaseHandler = mixin(
    {},
    web.mixins.AuthCookieMixin,
    web.mixins.PrincipalMixin
)

-- curl -v --cookie '_a=x' http://127.0.0.1:8080
-- curl -v -b /tmp/c.txt -c /tmp/c.txt http://127.0.0.1:8080
local AuthHandler = class(BaseHandler, {
    get = function(self)
        local p = self:get_principal()
        if not p then
            p = {
                id = 'john.smith',
                roles = {r1=true},
                alias = 'John Smith'
            }
            self:set_principal(p)
        end
        self.w:write('Hello, ' .. p.alias .. '!\n')
    end
})

-- url mapping

local all_urls = {
    {'', AuthHandler}
}

-- config

local options = {
    urls = all_urls,
    principal = principal,
    auth_cookie = {
        name = '_a',
        path = '/',
        deleted = http.cookie.delete {
            name = '_a',
            path = '/',
            --domain=c.domain
        }
    },
    ticket = ticket.new {
        --digest = digest.new('md5'),
        digest = digest.hmac('ripemd160', 'key1'),
        cipher = cipher.new('aes128', 'key2'),
        encoder = encoding.new('base64')
    }
}

return http.app({web.middleware.routing}, options)
