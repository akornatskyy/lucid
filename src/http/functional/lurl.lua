local request = require 'http.functional.request'
local writer = require 'http.functional.response'


local function usage()
    print([[
Usage: lurl [options...] <app> <path>
Options:
 -X COMMAND     Specify request command to use, e.g. POST
 -I             Fetch the headers only
 -H LINE        Pass custom header LINE, e.g. 'Accept: application/json'
 -d DATA        Request body data, e.g. '{"msg":"hello"}', 'msg=hello'
 -b             Issue a number of requests through iterations
 -v             Make the operation more talkative
]])
end

local function table_keys(t)
    local r = {}
    for key in next, t do
        table.insert(r, key)
    end
    return r
end

local function parse_qs(t, s)
    for kv in s:gmatch('([^&]+)') do
        local key, value = kv:match('([^=]*)=?(.*)')
        local v = t[key]
        if v then
            if type(v) == 'string' then
                t[key] = {v, value}
            else
                v[#v+1] = value
            end
        else
            t[key] = value
        end
    end
end

local function parse_path(path)
    local qs = {}
    local i = path:find('?', 1, true)
    if i then
        parse_qs(qs, path:sub(i + 1))
        path = path:sub(1, i - 1)
    end
    return path, qs
end

local function parse_args()
    local o, s, j
    local req = {headers = {}, body = {}}
    local args = {}
    local i = 1
    while i <= #arg - 2 do
        o, s = arg[i], arg[i+1]
        if o == '-X' and s then
            req.method = s:upper()
            i = i + 1
        elseif o == '-I' then
            args.headers_only = true
            if not req.method then
                req.method = 'HEAD'
            end
        elseif o == '-H' and s then
            j = s:find(': ')
            req.headers[s:sub(1, j - 1):lower()] = s:sub(j+2)
            i = i + 1
        elseif o == '-d' and s then
            local content_type = req.headers['content-type']
            local c = s:sub(1, 1)
            if c == '{' or c == '[' then
                local json = require 'core.encoding.json'
                req.body = json.decode(s)
                if not content_type then
                    req.headers['content-type'] = 'application/json'
                end
            else
                parse_qs(req.body, s)
                if not content_type then
                    req.headers['content-type'] =
                        'application/x-www-form-urlencoded'
                end
            end
            if not req.method then
                req.method = 'POST'
            end
            i = i + 1
        elseif o == '-v' then
            args.verbose = true
        elseif o == '-b' then
            args.bench = true
        else
            return
        end
        i = i + 1
    end
    req.path, req.query = parse_path(arg[#arg])
    return req, args
end

return function()
    if #arg < 2 then
        return usage()
    end

    local app = arg[#arg-1]
    app = app:find('%.lua$') and dofile(app) or require(app)
    if type(app) == 'table' then
        app = app.new()
    end

    local d, args = parse_args()
    if not d then
        return usage()
    end

    local req = request.new(d)
    local w = writer.new()
    app(w, req)

    if args.verbose then
        local pp = require 'core.pretty'
        req.options = nil
        io.write('req: ')
        print(pp.dump(req, pp.spaces.indented))
        io.write('w: ')
        if args.headers_only then
            w.buffer = nil
        end
        print(pp.dump(w, pp.spaces.indented))
    elseif args.bench then
        local clockit = require 'core.clockit'
        clockit.ptimes(function()
            app(writer.new(), request.new(d))
        end)
    elseif args.headers_only then
        print('HTTP/1.1 ' .. (w.status_code or '200 OK'))
        local names = table_keys(w.headers)
        table.sort(names)
        for _, name in ipairs(names) do
            print(name .. ': ' .. w.headers[name])
        end
    else
        local b = w.buffer
        if type(b) == 'table' then
            b = table.concat(b)
        end
        io.write(b)
    end
end
