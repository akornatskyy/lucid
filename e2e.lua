local requests = require 'requests'
local assert = require 'luassert'
local pretty = require 'core.pretty'

local function req(method, path, args)
    return requests.request(method, 'http://127.0.0.1:8080' .. path, args)
end

describe('hello', function()
    it('responds with hello world', function()
        local resp = req('GET', '/')

        assert.equals(200, resp.status_code)
        assert.equals('Hello World!\n', resp.text)
    end)

    it('responds with method not allowed status code', function()
        local resp = req('POST', '/')

        assert.equals(405, resp.status_code)
    end)

    it('responds with method not found status code', function()
        local resp = req('GET', '/x')

        assert.equals(404, resp.status_code)
    end)
end)

describe('api', function()
    it('responds with a list of tasks', function()
        local resp = req('GET', '/api/v1/tasks')

        assert.equals(200, resp.status_code)
        assert.equals('application/json', resp.headers['content-type'])
        local tasks = resp.json()
        assert.equals(3, #tasks)
    end)

    describe('get task', function()
        it('responds with not found status code', function()
            local resp = req('GET', '/api/v1/task/0')

            assert.equals(404, resp.status_code)
        end)

        it('returns a task by id', function()
            local resp = req('GET', '/api/v1/task/1')

            assert.equals(200, resp.status_code)
            assert.equals('application/json', resp.headers['content-type'])
            assert.same(
                {task_id = '1', title = 'Task #1', status = 1},
                resp.json()
            )
        end)
    end)

    describe('update task', function()
        it('responds with not found status code', function()
            local resp = req('PUT', '/api/v1/task/0')

            assert.equals(404, resp.status_code)
        end)

        it('responds with validation errors', function()
            local resp =
                req(
                'PUT',
                '/api/v1/task/1',
                {
                    headers = {['content-type'] = 'application/json'},
                    data = '{"title": ""}'
                }
            )

            assert.equals(400, resp.status_code)
            assert.equals('application/json', resp.headers['content-type'])
            assert.same({title = 'Required field cannot be left blank.'}, resp.json())
        end)

        it('succeeds', function()
            local resp =
                req(
                'PUT',
                '/api/v1/task/1',
                {
                    headers = {['content-type'] = 'application/json'},
                    data = '{"title": "Task X"}'
                }
            )

            assert.equals(200, resp.status_code)
            assert.equals('', resp.text)
        end)
    end)
end)
