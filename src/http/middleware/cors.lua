return function(following, options)
    local cors = assert(options.cors)
    return function(w, req)
        local headers = req.headers or req:parse_headers()
        -- is CORS request?
        local origin = headers['origin']
        if not origin then
            return following(w, req)
        end
        -- is same origin?
        local scheme, host, port = req:server_parts()
        local authority = scheme .. '://' .. host
          .. (port == '80' and '' or ':' .. port)
        if authority == origin then
            return following(w, req)
        end
        local allowed_origin = cors:check_origin(origin)
        if not allowed_origin then
            w:set_status_code(403)
            return w:write('origin is not allowed')
        end
        -- is pre flight request?
        local preflight = req.method == 'OPTIONS'
        local allowed_methods
        local allowed_headers
        if preflight then
            local request_method = headers['access-control-request-method']
            allowed_methods = cors:check_method(request_method)
            if not allowed_methods then
                w:set_status_code(403)
                return w:write('method is not allowed')
            end
            local request_headers = headers['access-control-request-headers']
            if request_headers then
                allowed_headers = cors:check_headers(request_headers)
                if not allowed_headers then
                    w:set_status_code(403)
                    return w:write('headers are not allowed')
                end
            end
        end
        w:add_header('Access-Control-Allow-Origin', allowed_origin)
        w:add_header('Vary', 'Origin')
        if cors.allow_credentials then
            w:add_header('Access-Control-Allow-Credentials', 'true')
        end
        if preflight then
            w:add_header('Access-Control-Allow-Methods', allowed_methods)
            w:add_header('Access-Control-Allow-Headers', allowed_headers)
            if cors.max_age then
                w:add_header('Access-Control-Max-Age', cors.max_age)
            end
            return w:set_status_code(204)
        else
            if cors.exposed_headers then
                w:add_header('Access-Control-Expose-Headers',
                             cors.exposed_headers)
            end
            return following(w, req)
        end
    end
end
