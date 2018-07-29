local http = require 'http'
local websocket = require 'http.middleware.websocket'

local app = http.app.new {
  websocket = {
      timeout = 30000
  }
}
app:use(http.middleware.routing)

app:get('echo', websocket, function(ws)
    ws:on('text', function(message)
        ws:send_text(message)
    end)
    ws:on('timeout', function()
        ws:close()
    end)

    ws:loop()
end)

return app()
