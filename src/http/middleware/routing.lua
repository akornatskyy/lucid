local assert = assert
_ENV = nil

return function(options)
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
        return handler(w, req)
    end
end
