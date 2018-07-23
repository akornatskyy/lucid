local class = require 'core.class'
local mixin = require 'core.mixin'

local length = require 'validation.rules.length'
local nonempty = require 'validation.rules.nonempty'
local required = require 'validation.rules.required'
local validator = require 'validation.validator'

local web = require 'web'


-- validation

local greeting_validator = validator.new {
    author = {required, nonempty, length{max=20}},
    message = {required, nonempty, length{min=5}, length{max=512}}
}

-- handlers

local BaseHandler = {}
mixin(BaseHandler, web.mixins.json, web.mixins.locale, web.mixins.validation,
      web.mixins.model)

--[[
    lurl -v -d '{"author":"jack","message":"hello"}' demos.web.form /
    lurl -v -X POST demos.web.form /
    curl -v -d "author=jack&message=hello" http://127.0.0.1:8080
    curl -v -H 'Content-Type: application/json' \
        -d '{"author":"jack","message":"hello"}' http://127.0.0.1:8080
    curl -v -X POST http://127.0.0.1:8080
--]]
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

return web.app({web.middleware.routing}, options)
