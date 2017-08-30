return function(following, options)
    assert(options.ticket, 'options.ticket')
    local name, path, domain, same_site, secure
    local cookie_dump, deleted_cookie
    local ticket = options.ticket
    local principal_dump

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
        principal_dump = assert(principal.dump)
        deleted_cookie = cookie.delete {name = name, path = path}
    end

    return function(w, req)
        following(w, req)
        local status_code = w:get_status_code()
        if status_code and status_code ~= 0 and (status_code > 299 or status_code < 200) then
            return
        end
        local p = w.principal
        if p then
            w:add_header('Set-Cookie', cookie_dump {
                name=name,
                value=ticket:encode(principal_dump(p)),
                path=path,
                domain=domain,
                same_site=same_site,
                secure=secure,
                http_only=true
            })
        else
            w:add_header('Set-Cookie', deleted_cookie)
        end
    end
end
