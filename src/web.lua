return {
    app = require 'web.app',
    middleware = {
        routing = require 'web.middleware.routing'
    },
    mixins = {
        authcookie = require 'web.mixins.authcookie',
        json = require 'web.mixins.json',
        locale = require 'web.mixins.locale',
        model = require 'web.mixins.model',
        principal = require 'web.mixins.principal',
        routing = require 'web.mixins.routing',
        set_error = require 'validation.mixins.set_error',
        validation = require 'validation.mixins.validation'
    }
}
