local websocket = require 'resty.websocket.server'

local Server = {}

function Server:on(cmd, handler)
  self.handlers[cmd] = handler
end

function Server:close()
  self.closed = true
end

function Server:loop()
  local ws = self.ws
  local handlers = self.handlers
  while not self.closed do
    local data, cmd, err = ws:recv_frame()
    if not data then
      if not string.find(err, ': timeout', 1, true) then
        break
      end
      cmd = 'timeout'
    end
    local handler = handlers[cmd]
    if handler then
      handler(data)
    end
    if cmd == 'close' then
      break
    end
  end
end

function Server:send_text(...)
  return self.ws:send_text(...)
end

function Server:send_binary(...)
  return self.ws:send_binary(...)
end

function Server:send_ping(...)
  return self.ws:send_ping(...)
end

function Server:send_close(...)
  return self.ws:send_close(...)
end

--

local Metatable = {__index = Server}

local function new(options)
  local ws, err = websocket:new(options)
  if not ws then
    return nil, err
  end
  return setmetatable({ws = ws, handlers = {}}, Metatable)
end

local function middleware(following, options)
  return function(w, req)
    local ws, err = new(options.websocket or {})
    if not ws then
      print(err)
      return w:set_status_code(400)
    end
    return following(ws, req)
  end
end

return middleware
