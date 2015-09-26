return {
    new = function(name)
        return require('core.encoding.' .. name)
    end,
    messagepack = require 'core.encoding.messagepack',
    json = require 'core.encoding.json'
}
