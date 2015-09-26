local clock = require('socket').gettime
local driver = require 'luasql.postgres'
local assert, format = assert, string.format


-- region: foundation

local Session = {__index = {
    fetchscalar = function(self, stmt, ...)
        local c = assert(self.c:execute(format(stmt, ...)))
        return c:fetch()
    end,
    fetchone = function(self, stmt, ...)
        local c = assert(self.c:execute(format(stmt, ...)))
        return c:fetch({}, 'a')
    end,
    fetchall = function(self, stmt, ...)
        local c = assert(self.c:execute(format(stmt, ...)))
        local i = 1
        local t = {}
        while true do
            local r = c:fetch({}, 'a')
            if not r then
                break
            end
            t[i] = r
            i = i + 1
        end
        return t
    end,
    escape = function(self, s)
        return self.c:escape(s)
    end,
    close = function(self)
        return self.c:close()
    end
}}

local function timeit(name, f, n, k)
    print(name)
    n = n or 5000
    k = k or 3
    for j = 1, k do
        local t = clock()
        for i = 1, n do
            f()
        end
        t = clock() - t
        print(format(' #%d => %.1frps', j, n / t))
    end
end

-- region: config

local env = assert(driver.postgres())
local session = setmetatable({c=assert(env:connect('dbname=main'))}, Session)
session.c:execute('SET default_transaction_read_only = on;')

-- region: repository

local function search_user(customer_id)
    return session:fetchall(
        "SELECT membership.search_user('%s')",
        customer_id)
end

local function get_user(user_id)
    return session:fetchone(
        "SELECT membership.get_user('%s')",
        user_id)
end

local function count_users(customer_id)
    return session:fetchscalar(
        "SELECT membership.count_users('%s')",
        customer_id)
end

-- region: test cases

timeit('get user', function()
    return get_user('1')
end)

timeit('search user', function()
    return search_user('10')
end)

timeit('count users', function()
    return count_users('10')
end)

-- region: close everything
session:close()
env:close()
