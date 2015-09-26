local pp = require 'core.pretty'
local mixin = require 'core.mixin'
local binder = require 'validation.binder'
local required = require 'validation.rules.required'
local validator = require 'validation.validator'

local http = require 'http'

mixin(http.Request, http.mixins.routing)
mixin(http.ResponseWriter, http.mixins.json)

local app = http.app.new()

app:use(function(options, following)
    return function(w, req)
        return following(w, req)
    end
end)
app:use(require 'http.middleware.routing')


-- decorators

local authorize = function(following)
    return function(w, req)
        return following(w, req)
    end
end

local check = function(following)
    return function(w, req)
        return following(w, req)
    end
end

-- handlers

local greeting_validator = validator.new({
    author = {required}
})

app
:get('', function(w, req)
    return w:write('Hello, world!\n')
end)
:post(authorize, check, function(w, req)
    local m = {author='', message=''}
    local b = binder.new()
    local values = req.form or req:parse_form()
    if not b:bind(m, values) or
            not b:validate(m, greeting_validator) then
        return w:json(b.errors, 400)
    end

    return w:json({message='Hello World!'})
end)

app:get('user/{name}', 'user', function(w, req)
    return w:write('Hello, ' .. req.route_args.name .. '!\n')
end)

return app()
