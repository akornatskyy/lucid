local mixin = require 'core.mixin'

local binder = require 'validation.binder'
local validator = require 'validation.validator'
local length = require 'validation.rules.length'
local required = require 'validation.rules.required'

local http = require 'http'


mixin(http.ResponseWriter, http.mixins.json)

local app = http.app.new()
app:use(http.middleware.routing)

local greeting_validator = validator.new {
    author = {length{max=20}},
    message = {required, length{min=5}, length{max=512}}
}

app:post('', function(w, req)
    local m = {author='', message=''}
    local b = binder.new()
    local values = req.body or req:parse_body()
    if not b:bind(m, values) or
            not b:validate(m, greeting_validator) then
        w:set_status_code(400)
        return w:json(b.errors)
    end
    return w:json(m)
end)

return app()
