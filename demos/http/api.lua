local mixin = require 'core.mixin'

local binder = require 'validation.binder'
local validator = require 'validation.validator'
local length = require 'validation.rules.length'
local required = require 'validation.rules.required'

local http = require 'http'


mixin(http.Request, http.mixins.routing)
mixin(http.ResponseWriter, http.mixins.json, {
    json_error = function(self, msg)
        self:set_status_code(400)
        return self:json({['__ERROR__'] = msg})
    end
})

local app = http.app.new {
    root_path = '/api/v1/'
}

app:use(http.middleware.routing)

-- validation

local task_validator = validator.new {
    title = {required, length{min=4}, length{max=250}},
    status = {required}
}

-- mock samples

local last_task_id = 3
local tasks = {
    ['1'] = {task_id='1', title='Task #1', status=1},
    ['2'] = {task_id='2', title='Task #2', status=2},
    ['3'] = {task_id='3', title='Task #3', status=1}
}

-- service

local function list_tasks()
    local r = {}
    for k, _ in pairs(tasks) do
        r[#r+1] = k
    end
    table.sort(r)
    for i = 1, #r do
        r[i] = tasks[r[i]]
    end
    return r
end

local function add_task(t)
    last_task_id = last_task_id + 1
    t.task_id = tostring(last_task_id)
    tasks[t.task_id] = t
    return true
end

local function get_task(task_id)
    return tasks[task_id]
end

local function update_task(t)
    if not tasks[t.task_id] then
        return false, 'Not Found.'
    end
    tasks[t.task_id] = t
    return true
end

local function remove_task(task_id)
    if not tasks[task_id] then
        return false
    end
    tasks[task_id] = nil
    return true
end

-- web handlers

-- curl -v http://localhost:8080/api/v1/urls
app:get('urls', function(w, req)
    return w:json({
        task_search_url = req:absolute_url_for('search_task'),
        task_url = req:absolute_url_for('task', {task_id='{task_id}'})
    })
end)

-- curl -v http://localhost:8080/api/v1/tasks
app:get('tasks', 'search_task', function(w, req)
    -- local query = req.query or req:parse_query()
    return w:json(list_tasks())
end)
-- curl -v -X POST http://localhost:8080/api/v1/tasks
-- curl -v -X POST -d 'title=TaskX' http://localhost:8080/api/v1/tasks
:post(function(w, req)
    local m = {title='', status=1}
    local b = binder.new()
    local values = req.body or req:parse_body()
    if not b:bind(m, values) or
            not b:validate(m, task_validator) then
        w:set_status_code(400)
        return w:json(b.errors)
    end
    local ok, msg = add_task(m)
    if not ok then
        return w:json_error(msg)
    end
    w:set_status_code(201)
    return w:json({task_id=m.task_id})
end)

-- curl -v http://localhost:8080/api/v1/task/1
app:get('task/{task_id:i}', 'task', function(w, req)
    local t = get_task(req.route_args.task_id)
    if not t then
        return w:set_status_code(404)
    end
    return w:json(t)
end)
-- curl -v -X PUT http://localhost:8080/api/v1/task/1
:put(function(w, req)
    local t = get_task(req.route_args.task_id)
    if not t then
        return w:set_status_code(404)
    end
    local b = binder.new()
    local values = req.body or req:parse_body()
    if not b:bind(t, values) or
            not b:validate(t, task_validator) then
        w:set_status_code(400)
        return w:json(b.errors)
    end
    local ok, msg = update_task(t)
    if not ok then
        return w:json_error(msg)
    end
end)
-- curl -v -X DELETE http://localhost:8080/api/v1/task/1
:delete(function(w, req)
    local ok = remove_task(req.route_args.task_id)
    if not ok then
        return w:set_status_code(404)
    end
end)

return app()
