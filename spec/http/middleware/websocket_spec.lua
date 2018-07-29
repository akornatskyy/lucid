insulate('websocket', function()
    local lib = {}
    package.loaded['resty.websocket.server'] = lib
    local websocket = require 'http.middleware.websocket'

    describe('middleware', function()
        setup(function()
            stub(_G, 'print')
        end)

        teardown(function()
            print:revert() -- luacheck: ignore 143
        end)

        it('unable to create a websocket', function()
            local options = {websocket = {timeout = 10000}}
            local middleware = websocket(nil, options)
            stub(lib, 'new')
            local w = {}
            stub(w, 'set_status_code')

            middleware(w)

            assert.stub(lib.new).called_with(lib, options.websocket)
            assert.stub(w.set_status_code).called_with(w, 400)
        end)

        it('calls handler', function()
            local handler = spy.new(function() end)
            local middleware = websocket(handler, {})
            stub(lib, 'new', {})

            middleware()

            assert.stub(lib.new).called_with(lib, {})
            assert.spy(handler).called(1)
        end)
    end)

    describe('server', function()
        local ws
        local socket = {}

        before_each(function()
            stub(lib, 'new', socket)
            websocket(function(_ws)
              ws = _ws
            end, {})()
        end)

        it('send text', function()
            stub(socket, 'send_text')

            ws:send_text('hi')

            assert.stub(socket.send_text).called_with(socket, 'hi')
        end)

        it('send binary', function()
            stub(socket, 'send_binary')

            ws:send_binary('hi')

            assert.stub(socket.send_binary).called_with(socket, 'hi')
        end)

        it('send ping', function()
            stub(socket, 'send_ping')

            ws:send_ping('hi')

            assert.stub(socket.send_ping).called_with(socket, 'hi')
        end)

        it('send close', function()
            stub(socket, 'send_close')

            ws:send_close('hi')

            assert.stub(socket.send_close).called_with(socket, 'hi')
        end)

        it('close', function()
            ws:close()

            assert.is_true(ws.closed)
        end)

        it('registers a command handler', function()
            ws:on('text', function()
            end)

            assert.not_nil(ws.handlers['text'])
        end)

        describe('loop', function()
            it('exits on socket error', function()
                stub(socket, 'recv_frame', nil, nil, 'error')

                ws:loop()
            end)

            it('exits on close command', function()
                stub(socket, 'recv_frame', '', 'close')

                ws:loop()
            end)

            it('calls close command handler and exits', function()
                stub(socket, 'recv_frame', 'msg', 'close')
                local handler = spy.new(function() end)
                ws:on('close', handler)

                ws:loop()

                assert.spy(handler).called_with('msg')
            end)

            it('handles timeout error', function()
                stub(socket, 'recv_frame', nil, '', ': timeout')
                local handler = spy.new(function()
                    ws:close()
                end)
                ws:on('timeout', handler)

                ws:loop()

                assert.spy(handler).called_with(nil)
            end)

            it('handles text', function()
                stub(socket, 'recv_frame', 'hi', 'text')
                local handler = spy.new(function()
                    ws:close()
                end)
                ws:on('text', handler)

                ws:loop()

                assert.spy(handler).called_with('hi')
            end)
        end)
    end)
end)
