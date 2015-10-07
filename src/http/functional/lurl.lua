local request = require 'http.functional.request'
local setmetatable = setmetatable


local function usage()
    print([[
Usage: lurl [options...] <app> <path>
Options:
 -X COMMAND     Specify request command to use, e.g. POST
 -H LINE        Pass custom header LINE, e.g. 'Accept: application/json'
 -d DATA        Request body data, e.g. '{"msg":"hello"}', 'msg=hello'
 -b             Issue a number of requests through iterations
 -v             Make the operation more talkative
]])
end

local function parse_args()
    local o, s, j
    local req = {path = arg[#arg], headers={}, body={}}
    local args = {i = 3, n = 100000}
    local i = 1
    while i <= #arg - 2 do
        o, s = arg[i], arg[i+1]
        if o == '-X' and s then
            req.method = s
            i = i + 1
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
                for kv in s:gmatch('([^&]+)') do
                    local key, value = kv:match('([^=]*)=?(.*)')
                    req.body[key] = value
                end
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

    local req, args = parse_args()
    if not req then
        return usage()
    end
    req = request.new(req)

    local w
    if args.bench then
        w = require 'http.response'
        w = setmetatable({headers = {}}, {__index = w})
    else
        w = require 'http.functional.response'
        w = w.new()
    end

    app(w, req)

    if args.verbose then
        local pp = require 'core.pretty'
        req.options = nil
        print('req: ' .. pp.dump(req, pp.spaces.indented))
        print('w: ' .. pp.dump(w, pp.spaces.indented))
    elseif args.bench then
        local clockit = require 'core.clockit'
        clockit.ptimes(function()
            app(w, req)
        end)
    else
        io.write(table.concat(w.buffer))
    end
end
