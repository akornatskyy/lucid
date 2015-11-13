local assert, setmetatable = assert, setmetatable


return function(following, options)
    if not options.root_path then
        options.root_path = '/'
    end
    local r = options.router
    if not r then
        r = require 'routing.router'
        r = r.new{root_path=options.root_path}
        options.router = r
    end
    assert(r:add(options.urls))
    return function(w, req)
        local handler, args = r:match_root(req.path)
        if not handler then
            return w:set_status_code(404)
        end
        req.route_args = args
        req.options = options
        handler = setmetatable({w = w, req = req}, handler)
        local m = req.method
        if m == 'GET' then
            m = handler.get
        elseif m == 'POST' then
            m = handler.post
        elseif m == 'PUT' then
            m = handler.put
        elseif m == 'DELETE' then
            m = handler.delete
        elseif m == 'PATCH' then
            m = handler.patch
        elseif m == 'HEAD' then
            m = handler.head
        elseif m == 'OPTIONS' then
            m = handler.options
        else
            return w:set_status_code(405)
        end
        if m then
            return m(handler)
        end
        return w:set_status_code(405)
    end
end
