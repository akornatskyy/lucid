return {
    app = require 'http.app',
    cookie = require 'http.cookie',
    Request = require 'http.request',
    ResponseWriter = require 'http.response',
    middleware = {
        routing = require 'http.middleware.routing'
    },
    mixins = {
        json = require 'http.mixins.json',
        routing = require 'http.mixins.routing'
    }
}
