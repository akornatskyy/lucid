return {
    app = require 'http.app',
    cookie = require 'http.cookie',
    cors = require 'http.cors',
    Request = require 'http.request',
    ResponseWriter = require 'http.response',
    middleware = {
        authcookie = require 'http.middleware.authcookie',
        authorize = require 'http.middleware.authorize',
        caching = require 'http.middleware.caching',
        cors = require 'http.middleware.cors',
        routing = require 'http.middleware.routing'
    },
    mixins = {
        json = require 'http.mixins.json',
        routing = require 'http.mixins.routing'
    }
}
