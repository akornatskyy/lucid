local dump
do
    local cookie = require 'http.cookie'
    dump = cookie.dump
end

return function(following, options)
    assert(options.ticket, 'options.ticket')
    local name, path, domain, secure
    local ticket = options.ticket
    local principal

    do
        local c = options.auth_cookie or {}
        name = c.name or '_a'
        path = c.path or options.root_path or '/'
        domain = c.domain
        secure = c.secure
        principal = options.principal or require 'security.principal'
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
        end
    end
end
