local require, next, type = require, next, type
local assert, load = assert, loadstring
local format, concat = string.format, table.concat
local setmetatable = setmetatable
-- local pp = require 'core.pretty'


local function build_route(builders, pattern, finishing, args)
    for i = 1, #builders do
        local r = builders[i](pattern, finishing, args)
        if r then
            return r
        end
    end
    return false, 'no matching route factory found'
end

local function tblmerge(t1, t2)
    local r = {}
    for k, v in next, t1 do
        r[k] = v
    end
    for k, v in next, t2 do
        r[k] = v
    end
    return r
end

local function fmtadd(t1, t2)
    local r = {}
    for i = 1, #t1 do
        r[i] = t1[i]
    end
    local s
    if #r % 2 == 1 then
        r[#r] = r[#r] .. t2[1]
        s = 2
    else
        s = 1
    end
    for i = s, #t2 do
        r[#r+1] = t2[i]
    end
    return r
end

local function gen_path(fmt)
    local t = {}
    for i = 1, #fmt do
        local s = fmt[i]
        if s ~= '' then
            if i % 2 == 0 then
                t[#t+1] = format('(t[%q] or d[%q])', s, s)
            else
                t[#t+1] = format('%q', s)
            end
        end
    end
    return format([[
        _ENV = nil
        return function(t, d)
            return %s
        end
    ]], concat(t, ' .. '))
end

local Router = {}
local mt = {__index = Router}

local function new(self)
    if not self then
        self = {}
    end
    if not self.builders then
        self.builders = require('routing.builders')
    end
    if self.root_path then
        self.match_skip = self.root_path:len() + 1
    end
    self.match_map = {}
    self.mapping = {}
    self.path_map = {}
    self.fmt_map = {}
    return setmetatable(self, mt)
end

local function add_route(self, pattern, handler, args, name)
    args = args or {}
    args.route_name = name
    local route = build_route(self.builders, pattern, true, args)
    if name then
        if self.fmt_map[name] then
            return false, format('overriding name %q', name)
        end
        self.fmt_map[name] = {route.fmt, args}
        route.fmt = nil
    end
    if route.exact_matches then
        for p, a in next, route.exact_matches do
            if self.match_map[p] then
                return false, format('overriding path %q', p)
            end
            self.match_map[p] = {handler, a}
        end
        route.exact_matches = nil
    else
        self.mapping[#self.mapping+1] = {route, handler}
    end
    return true
end

local function include(self, pattern, included, args)
    local r
    if not included.add then
        r = new({builders=self.builders})
        r.path_map = nil
        local ok, msg = r:add(included)
        if not ok then
            return ok, msg
        end
        included = r
    end
    args = args or {}
    r = build_route(self.builders, pattern, false, args)
    if r.exact_matches then
        for p, a in next, r.exact_matches do
            for k, v in next, included.match_map do
                k = p .. k
                if self.match_map[k] then
                    return false, format('overriding path %q', k)
                end
                local h, kw = v[1], v[2]
                self.match_map[k] = {h, tblmerge(a, kw)}
            end
        end
        r.exact_matches = nil
        included.match_map = {}
        if #included.mapping > 0 then
            self.mapping[#self.mapping+1] = {r, included}
        end
    else
        self.mapping[#self.mapping+1] = {r, included}
    end
    for name, m in next, included.fmt_map do
        if self.fmt_map[name] then
            return false, format('overriding name %q', name)
        end
        self.fmt_map[name] = {fmtadd(r.fmt, m[1]), tblmerge(args, m[2])}
    end
    r.fmt = nil
    included.fmt_map = nil
    included.builders = nil
    return true
end

local function scan(mapping, path)
    for i = 1, #mapping do
        local m = mapping[i]
        local r = m[1]
        local matched, t1 = r:match(path)
        if matched then
            r = m[2]
            if type(r) ~= 'table' or not r.match then
                return r, t1
            end
            local h, t2 = r:match(path:sub(matched + 1))
            if h then
                if not t1 then
                    return h, t2
                end
                if t2 then
                    return h, tblmerge(t1, t2)
                end
                return h, t1
            end
        end
    end
    return nil
end

function Router:add(mapping)
    for i = 1, #mapping do
        local m = mapping[i]
        local pattern, handler, args, name = m[1], m[2], m[3], m[4]
        args = args or m.args
        name = name or m.name
        if type(handler) == 'table' and handler[1] then
            local ok, msg = include(self, pattern, handler, args)
            if not ok then
                return ok, msg
            end
        else
            local ok, msg = add_route(self, pattern, handler, args, name)
            if not ok then
                return ok, msg
            end
        end
    end
    if self.path_map then
        local root_path = self.root_path
        for name, m in next, self.fmt_map do
            if self.path_map[name] then
                return false, format('overriding name %q', name)
            end
            local fmt, args = m[1], m[2]
            if root_path then
                fmt[1] = root_path .. fmt[1]
            end
            self.path_map[name] = assert(load(gen_path(fmt, args)))()
        end
        self.fmt_map = nil
    end
    return true
end

function Router:match(path)
    local m = self.match_map[path]
    if m then
        return m[1], m[2]
    end
    return scan(self.mapping, path)
end

function Router:match_root(path)
    path = path:sub(self.match_skip)
    local m = self.match_map[path]
    if m then
        return m[1], m[2]
    end
    return scan(self.mapping, path)
end

function Router:path_for(name, args, defaults)
    return self.path_map[name](args, defaults)
end

return {
    new = new
}
