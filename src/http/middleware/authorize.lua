return function(following, options)
    assert(options.ticket, 'options.ticket')
    local name, path, domain, same_site, secure
    local cookie_dump, deleted_cookie
    local ticket = options.ticket
    local principal_parse

    do
        local cookie = require 'http.cookie'
        local c = options.auth_cookie or {}
        cookie_dump = cookie.dump
        name = c.name or '_a'
        path = c.path or options.root_path or '/'
        domain = c.domain
        same_site = c.same_site
        secure = c.secure
        local principal = options.principal or require 'security.principal'
        principal_parse = assert(principal.parse)
        deleted_cookie = cookie.delete {name = name, path = path}
    end

    return function(w, req)
        local c = req:get_cookie(name)
        if not c then
            return w:set_status_code(401)
        end
        local p, time_left = ticket:decode(c)
        if not p then
            w:add_header('Set-Cookie', deleted_cookie)
            return w:set_status_code(401)
        end
        if time_left < ticket.max_age / 2 then
            w:add_header('Set-Cookie', cookie_dump {
                name=name,
                value=ticket:encode(p),
                path=path,
                domain=domain,
                same_site=same_site,
                secure=secure,
                http_only=true
            })
        end
        req.principal = principal_parse(p)
        return following(w, req)
    end
end
