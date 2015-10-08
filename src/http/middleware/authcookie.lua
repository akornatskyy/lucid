return function(following, options)
    assert(options.ticket, 'options.ticket')
    local name, path, domain, secure
    local dump, deleted
    local ticket = options.ticket
    local principal

    do
        local cookie = require 'http.cookie'
        local c = options.auth_cookie or {}
        dump = cookie.dump
        name = c.name or '_a'
        path = c.path or options.root_path or '/'
        domain = c.domain
        secure = c.secure
        principal = options.principal or require 'security.principal'
        deleted = cookie.delete {name = name, path = path}
    end

    return function(w, req)
        following(w, req)
        local p = w.principal
        if p then
            w:add_header('Set-Cookie', dump({
                name=name,
                value=ticket:encode(principal.dump(p)),
                path=path,
                domain=domain,
                secure=secure,
                http_only=true
            }))
        else
            w:add_header('Set-Cookie', deleted)
        end
    end
end
