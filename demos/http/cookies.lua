local http = require 'http'

local app = http.app.new()
app:use(http.middleware.routing)

app:get('', function(w)
    w:set_cookie(http.cookie.dump {
        name = 'm', value = 'hello', path = '/'
    })
    w:set_cookie(http.cookie.dump {
        name = 'c', value = '100', http_only = true
    })
end)

app:get('remove', function(w)
    w:set_cookie(http.cookie.delete {name = 'c'})
end)

return app()
