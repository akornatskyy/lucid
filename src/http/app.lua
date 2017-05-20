local assert, setmetatable, rawget, type = assert, setmetatable, rawget, type
local insert = table.insert

local App, AppMeta = {}, {}
local http_verbs = {
    delete = 'DELETE',
    get = 'GET',
    head = 'HEAD',
    patch = 'PATCH',
    post = 'POST',
    put = 'PUT'
}

local pack_wrappers = function(handlers, options)
    local h = handlers[#handlers]
    for i = #handlers - 1, 1, -1 do
        h = handlers[i](h, options)
    end
    return h
end

local http_method_wrapper = function(mapping)
    return function(w, req)
        local handler = mapping[req.method]
        if not handler then
            return w:set_status_code(405)
        end
        return handler(w, req)
    end
end

local function build_url_mapping(self)
    local urls = self.options.urls
    for i = 1, #self.ordered do
        local path = self.ordered[i]
        local mapping  = self.mapping[path]
        if mapping then
            local name = mapping.name
            mapping.name = nil
            urls[#urls+1] = {
                path,
                http_method_wrapper(mapping),
                name=name
            }
            self.mapping[path] = nil
        end
    end
    self.mapping = nil
    self.ordered = nil
end

local RouteBuilder = {}

function RouteBuilder:__index(method)
    local http_verb = http_verbs[method] or method
    return function(_, name_or_func, ...)
        local handlers = {...}
        if self ~= _ then
            insert(handlers, 1, name_or_func)
            name_or_func = _
        end
        local mapping = self.mapping[self.pattern]
        if mapping then
            assert(not mapping[http_verb])
        else
            mapping = {}
            self.mapping[self.pattern] = mapping
        end
        if rawget(self, 'name') then
            mapping.name = self.name
        end
        if type(name_or_func) == 'string' then
            mapping.name = name_or_func
        else
            insert(handlers, 1, name_or_func)
        end
        mapping[http_verb] = pack_wrappers(handlers, self.options)
        self.ordered[#self.ordered+1] = self.pattern
        return self
    end
end

local function new(options)
    options = options or {}
    if not options.urls then
        options.urls = {}
    end
    return setmetatable({
        options = options,
        middlewares = {},
        ordered = {},
        mapping = {},
    }, AppMeta)
end

function App:use(middleware)
    self.middlewares[#self.middlewares+1] = middleware
end

function App:add(pattern, app)
    local urls = self.options.urls
    build_url_mapping(app)
    urls[#urls+1] = {pattern, app.options.urls}
end

-- app:all('pattern', ['route_name',] [function(following), ...] function(w, req)
function App:all(pattern, name_or_func, ...)
    local r
    local handlers = {...}
    if type(name_or_func) == 'string' then
        r = {pattern, pack_wrappers(handlers, self.options), name=name_or_func}
    else
        insert(handlers, 1, name_or_func)
        r = {pattern, pack_wrappers(handlers, self.options)}
    end
    self.options.urls[#self.options.urls+1] = r
end

-- app:route('pattern' [, 'name']):post(function(w, req) ...
-- app:route('pattern' [, 'name'])['OPTIONS'](function(w, req) ...
function App:route(pattern, name)
    return setmetatable({
        pattern = pattern,
        name = name,
        mapping = self.mapping,
        ordered = self.ordered,
        options = self.options
    }, RouteBuilder)
end

-- app:post(pattern, [route_name,] function(w, req) ...
function AppMeta:__index(name)
    return App[name] or function(_, pattern, ...)
        local r = self:route(pattern)
        return r[name](r, ...)
    end
end

local function chain_middlewares(self)
    local following
    for i = #self.middlewares, 1, -1 do
        following = self.middlewares[i](following, self.options)
    end
    assert(following, 'no middleware in use')
    return following
end

function AppMeta:__call()
    build_url_mapping(self)
    return chain_middlewares(self)
end

return {
    new = new,
    http_verbs = http_verbs
}
