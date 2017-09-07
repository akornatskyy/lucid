-- https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS
local concat = table.concat

local function fromkeys(t)
    local r = {}
    for _, k in next, t do
        r[k] = true
    end
    return r
end

local Checker = {}
local mt = {__index = Checker}

function Checker:check_origin(origin)
    if self.allowed_origins['*'] then
        return self.allow_credentials and origin or '*'
    end
    if self.allowed_origins[origin] then
        return origin
    end
    return nil
end

function Checker:check_method(method)
    if self.allowed_methods[method] then
        return self.allowed_methods_string
    end
    return nil
end

function Checker:check_headers(headers)
    if self.allowed_headers['*'] then
        return headers
    end
    local allowed_headers = {}
    for header in headers:gmatch('([^,]+)') do
        if self.allowed_headers[header] then
            allowed_headers[#allowed_headers+1] = header
        end
    end
    if next(allowed_headers) then
        return concat(allowed_headers, ',')
    end
    return nil
end

local defaults = {
  allowed_origins = {},
  allowed_methods = {'GET', 'HEAD'},
  allowed_headers = {}
}

local function new(options)
    assert(options)
    local self = {}
    for k, v in next, defaults do
       self[k] = v
    end
    if options.allowed_origins then
        self.allowed_origins = fromkeys(options.allowed_origins)
    end
    if options.allow_credentials and self.allowed_origins['*'] then
        self.allow_credentials = options.allow_credentials
    end
    if options.allowed_headers then
        self.allowed_headers = fromkeys(options.allowed_headers)
    end
    if options.allowed_methods then
        self.allowed_methods = options.allowed_methods
    end
    self.allowed_methods_string = concat(self.allowed_methods, ',')
    self.allowed_methods = fromkeys(self.allowed_methods)
    if options.max_age then
        self.max_age = tostring(options.max_age)
    end
    if options.exposed_headers then
        self.exposed_headers = concat(options.exposed_headers, ',')
    end
    return setmetatable(self, mt)
end

return {
    new = new,
    defaults = defaults
}
