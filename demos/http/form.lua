local mixin = require 'core.mixin'

local binder = require 'validation.binder'
local validator = require 'validation.validator'
local length = require 'validation.rules.length'
local required = require 'validation.rules.required'

local http = require 'http'


mixin(http.ResponseWriter, http.mixins.json)

local app = http.app.new()
app:use(http.middleware.routing)

-- validation

local greeting_validator = validator.new({
    author = {required, length{max=20}},
    message = {required, length{min=5}, length{max=512}}
})

--[[
    lurl -v -d '{"author":"jack","message":"hello"}' demos.http.form /
    lurl -v -X POST demos.http.form /
    curl -v -d "author=jack&message=hello" http://127.0.0.1:8080
    curl -v -X POST http://127.0.0.1:8080
--]]
app:post('', function(w, req)
    local m = {author='', message=''}
    local b = binder.new()
    local values = req.body or req:parse_body()
    if not b:bind(m, values) or
            not b:validate(m, greeting_validator) then
        return w:json(b.errors, 400)
    end
end)

return app()

