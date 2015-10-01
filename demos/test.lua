local mixin = require 'core.mixin'
local encoding = require 'core.encoding'

local binder = require 'validation.binder'
local validator = require 'validation.validator'
local length = require 'validation.rules.length'
local required = require 'validation.rules.required'

local cipher = require 'security.crypto.cipher'
local digest = require 'security.crypto.digest'
local ticket = require 'security.crypto.ticket'

local http = require 'http'


mixin(http.Request, http.mixins.routing)
mixin(http.ResponseWriter, http.mixins.json)

local authorize = http.middleware.authorize
local authcookie = http.middleware.authcookie
local app = http.app.new {
    ticket = ticket.new {
        digest = digest.hmac('ripemd160', 'key1'),
        cipher = cipher.new('aes256', 'key2'),
        encoder = encoding.new('base64')
    }
}

-- middleware
--[[
app:use(function(following, options)
    return function(w, req)
        return following(w, req)
    end
end)
--]]
app:use(http.middleware.routing)

-- handlers

local greeting_validator = validator.new {
    author = {required, length{max=20}},
    message = {required, length{min=5}, length{max=512}}
}

--[[
    lurl -v demos.test /
    lurl -v -d '{"author":"jack","message":"hello"}' demos.test /
    lurl -v -X POST demos.test /
--]]
app:get('', function(w, req)
    return w:write('Hello World!\n')
end)
:post(function(w, req)
    local m = {author='', message=''}
    local b = binder.new()
    local values = req.form or req:parse_form()
    if not b:bind(m, values) or
            not b:validate(m, greeting_validator) then
        return w:json(b.errors, 400)
    end
    return w:json({
        message='Hello World!',
        path=req:absolute_url_for('user', {name='jack'})
    })
end)

-- lurl -v demos.test /user/jack
app:get('user/{name}', 'user', function(w, req)
    return w:write('Hello, ' .. req.route_args.name .. '!\n')
end)

-- lurl -v -H 'Cookie: _a=' demos/test.lua /secure
app:get('secure', authorize, function(w, req)
    return w:write('Hello World!\n')
end)

-- lurl -v demos/test.lua /signin
app:get('signin', authcookie, function(w, req)
    w.principal = {id = 'john.smith', roles = {admin=true}}
end)

return app()
