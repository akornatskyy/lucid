local request = require 'http.functional.request'
local writer = require 'http.functional.response'
local json = require 'core.encoding.json'
local describe, it, assert = describe, it, assert

local function test_cases(app)
	assert.not_nil(app)

	it('responds with urls', function()
        local w = writer.new()
        local req = request.new({path = '/api/v1/urls'})
        app(w, req)
        assert.is_nil(w.status_code)
        assert.same({['Content-Type'] = 'application/json'}, w.headers)
        local urls = json.decode(table.concat(w.buffer))
        assert.equals('http://localhost:8080/api/v1/tasks',
                      urls.task_search_url)
        assert.equals('http://localhost:8080/api/v1/task/{task_id}',
                      urls.task_url)
	end)

	it('responds with tasks', function()
        local w = writer.new()
        local req = request.new({path = '/api/v1/tasks'})
        app(w, req)
        assert.is_nil(w.status_code)
        assert.same({['Content-Type'] = 'application/json'}, w.headers)
        assert(json.decode(table.concat(w.buffer)))
	end)

    describe('add task', function()
        it('validates', function()
            local w = writer.new()
            local req = request.new({
                method = 'POST',
                path = '/api/v1/tasks'
            })
            app(w, req)
            assert.equals(400, w.status_code)
        end)

        it('adds', function()
            local w = writer.new()
            local req = request.new({
                method = 'POST',
                path = '/api/v1/tasks',
                form = {title = 'Task X'}
            })
            app(w, req)
            assert.equals(201, w.status_code)
        end)
    end)

    describe('get task', function()
        it('responds with not found status code', function()
            local w = writer.new()
            local req = request.new({path = '/api/v1/task/0'})
            app(w, req)
            assert.equals(404, w.status_code)
        end)

        it('returns a task', function()
            local w = writer.new()
            local req = request.new({path = '/api/v1/task/1'})
            app(w, req)
            assert.is_nil(w.status_code)
            assert.same({['Content-Type'] = 'application/json'}, w.headers)
            assert(json.decode(table.concat(w.buffer)))
        end)
    end)

    describe('update task', function()
        it('responds with not found status code', function()
            local w = writer.new()
            local req = request.new({
                method = 'PUT',
                path = '/api/v1/task/0'
            })
            app(w, req)
            assert.equals(404, w.status_code)
        end)

        it('validates', function()
            local w = writer.new()
            local req = request.new({
                method = 'PUT',
                path = '/api/v1/task/1',
                form = {title = ''}
            })
            app(w, req)
            assert.equals(400, w.status_code)
        end)

        it('updates a task', function()
            local w = writer.new()
            local req = request.new({
                method = 'PUT',
                path = '/api/v1/task/1',
                form = {title = 'Task X'}
            })
            app(w, req)
            assert.is_nil(w.status_code)
        end)
    end)

    describe('remove task', function()
        it('responds with not found status code', function()
            local w = writer.new()
            local req = request.new({
                method = 'DELETE',
                path = '/api/v1/task/0'
            })
            app(w, req)
            assert.equals(404, w.status_code)
        end)

        it('removes a task', function()
            local w = writer.new()
            local req = request.new({
                method = 'DELETE',
                path = '/api/v1/task/2'
            })
            app(w, req)
            assert.is_nil(w.status_code)
        end)
    end)
end

describe('demos.http.api', function()
    test_cases(require 'demos.http.api')
end)

describe('demos.web.api', function()
    test_cases(require 'demos.web.api')
end)
