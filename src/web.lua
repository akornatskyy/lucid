_ENV = nil

return {
    middleware = {
        routing = require 'web.middleware.routing'
    },
    mixins = {
        AuthCookieMixin = require 'web.mixins.authcookie',
        ModelMixin = require 'web.mixins.model',
        PrincipalMixin = require 'web.mixins.principal',
        RoutingMixin = require 'web.mixins.routing',
        JSONMixin = require 'web.mixins.json'
    }
}
