local class = require 'core.class'
local mixin = require 'core.mixin'

local length = require 'validation.rules.length'
local nonempty = require 'validation.rules.nonempty'
local required = require 'validation.rules.required'
local validator = require 'validation.validator'

local web = require 'web'

-- validation

local task_validator = validator.new {
    title = {required, nonempty, length{min=4}, length{max=250}},
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

local BaseHandler = {
    json_error = function(self, msg)
        self.w:set_status_code(400)
        return self:json({['__ERROR__'] = msg})
    end
}

mixin(BaseHandler, web.mixins.json, web.mixins.locale, web.mixins.validation,
      web.mixins.model, web.mixins.routing)

local WelcomeHandler = class(BaseHandler, {})
-- curl -v http://localhost:8080/api/v1/urls
function WelcomeHandler:get()
    return self:json({
        task_search_url = self:absolute_url_for('search_task'),
        task_url = self:absolute_url_for('task', {task_id='{task_id}'})
    })
end

local TasksHandler = class(BaseHandler, {
    -- curl -v http://localhost:8080/api/v1/tasks
    get = function(self)
        return self:json(list_tasks())
    end,
    -- curl -v -X POST http://localhost:8080/api/v1/tasks
    -- curl -v -X POST -d 'title=TaskX' http://localhost:8080/api/v1/tasks
    post = function(self)
        local m = {title='', status=1}
        self.errors = {}
        if not self:update_model(m) or
                not self:validate(m, task_validator) then
            return self:json_errors()
        end
        local ok, msg = add_task(m)
        if not ok then
            return self:json_error(msg)
        end
        self.w:set_status_code(201)
        return self:json({task_id=m.task_id})
    end
})

local TaskHandler = class(BaseHandler, {
    -- curl -v http://localhost:8080/api/v1/task/1
    get = function(self)
        local t = get_task(self.req.route_args.task_id)
        if not t then
            return self.w:set_status_code(404)
        end
        return self:json(t)
    end,
    -- curl -v -X PUT http://localhost:8080/api/v1/task/1
    put = function(self)
        local t = get_task(self.req.route_args.task_id)
        if not t then
            return self.w:set_status_code(404)
        end
        self.errors = {}
        if not self:update_model(t) or
                not self:validate(t, task_validator) then
            return self:json_errors()
        end
        local ok, msg = update_task(t)
        if not ok then
            return self:json_error(msg)
        end
    end,
    -- curl -v -X DELETE http://localhost:8080/api/v1/task/1
    delete = function(self)
        local ok = remove_task(self.req.route_args.task_id)
        if not ok then
            return self.w:set_status_code(404)
        end
    end
})

-- url mapping

local all_urls = {
    {'urls', WelcomeHandler},
    {'tasks', TasksHandler, name='search_task'},
    {'task/{task_id:i}', TaskHandler, name='task'}
}

-- config

local options = {
    root_path = '/api/v1/',
    urls = all_urls
}

return web.app({web.middleware.routing}, options)
