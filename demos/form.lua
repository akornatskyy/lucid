local class = require 'core.class'
local mixin = require 'core.mixin'
local i18n = require 'core.i18n'
local length = require 'validation.rules.length'
local required = require 'validation.rules.required'
local validator = require 'validation.validator'
local web = require 'web'
_ENV = nil


i18n = i18n.configure()

-- validation

local greeting_validator = validator.new({
    author = {required, length{max=20}},
    message = {required, length{min=5}, length{max=512}}
})

-- handlers

local BaseHandler = mixin({
    translation = i18n.domains['demo']
}, web.mixins.JSONMixin, web.mixins.ModelMixin)


-- curl -i --data "author=jack&message=hello" http://127.0.0.1:8080
local FormHandler = class(BaseHandler, {
    post = function(self)
        local m = {author='', message=''}
        self.errors = {}
        if not self:update_model(m) or
                not self:validate(m, greeting_validator) then
            return self:json_errors()
        end
    end
})

-- url mapping

local all_urls = {
    {'', FormHandler}
}

-- config

local options = {
    urls = all_urls
}

local app = web.app({web.middleware.routing}, options)
if not debug.getinfo(3) then
    local clockit = require 'core.clockit'
    local request = require 'http.functional.request'
    local writer = require 'http.functional.response'
    local w = writer.new()

    local req = request.new({
        method = 'POST',
    })
    print('failed:')
    clockit.ptimes(function()
        app(w, req)
    end)

    req = request.new({
        method = 'POST',
        form = {author = 'jack', message = 'hello'}
    })
    print('succeed:')
    clockit.ptimes(function()
        app(w, req)
    end)
end
return app
