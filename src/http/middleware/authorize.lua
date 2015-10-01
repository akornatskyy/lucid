local dump
do
    local cookie = require 'http.cookie'
    dump = cookie.dump
end


return function(following, options)
    assert(options.ticket, 'options.ticket')
    local name, path, domain, secure, deleted
    local ticket = options.ticket
    local principal

    do
        local cookie = require 'http.cookie'
        local c = options.auth_cookie or {}
        name = c.name or '_a'
        path = c.path or options.root_path or '/'
        domain = c.domain
        secure = c.secure
        deleted = cookie.delete {name = name, path = path}
        principal = options.principal or require 'security.principal'
    end

    return function(w, req)
        local c = req:get_cookie(name)
        if not c then
            return w:set_status_code(401)
        end
        local p, time_left = ticket:decode(c)
        if p then
            if time_left < ticket.max_age / 2 then
                w:add_header('Set-Cookie', dump({
                    name=name,
                    value=ticket:encode(p),
                    path=path,
                    domain=domain,
                    secure=secure,
                    http_only=true
                }))
            end
            req.principal = principal.parse(p)
        else
            w:add_header('Set-Cookie', deleted)
            return w:set_status_code(401)
        end
        return following(w, req)
    end
end
