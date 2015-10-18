local router = require 'routing.router'

local user_urls = {
    {'', 4, name='user'},
    {'/groups', 5, name='user_groups'},
    {'/group/{group:w}', 6, name='user_group'}
}
local membership_urls = {
    {'users', 2, name='user_list'},
    {'users/add', 3, name='add_user', args={user_id=''}},
    {'user/{user_id:i}', user_urls}
}
local all_urls = {
    {'/', 1, name='default'},
    {'/{locale:(en|de)}/', membership_urls},
    {'/static/{path:any}', 10, name='static'}
}

describe('router', function()
    describe('ctor', function()
        it('fallbacks to default builders', function()
            local builders = require('routing.builders')
            local r = router.new()
            assert.equals(builders, r.builders)
        end)

        it('accepts builders', function()
            local builders = {}
            local r = router.new {builders=builders}
            assert.equals(builders, r.builders)
        end)
    end)

    describe('add', function()
        it('fails to override route name', function()
            local r = router.new()
            local ok, msg = r:add {
                {'1', 1, name='x'},
                {'2', 2, name='x'}
            }
            assert.is_false(ok)
            assert.equals('overriding name "x"', msg)
        end)

        it('fails to override route name in included', function()
            local r = router.new()
            local ok, msg = r:add {
                {'1', 1, name='x'},
                {'2', {
                    {'3', 2, name='x'}
                }}
            }
            assert.is_false(ok)
            assert.equals('overriding name "x"', msg)
        end)

        it('fails to override route path', function()
            local r = router.new()
            local ok, msg = r:add {
                {'1', 1},
                {'1', 2}
            }
            assert.is_false(ok)
            assert.equals('overriding path "1"', msg)
        end)

        it('fails to override route path in included', function()
            local r = router.new()
            local ok, msg = r:add {
                {'1', 1},
                {'', {
                    {'1', 2}
                }}
            }
            assert.is_false(ok)
            assert.equals('overriding path "1"', msg)
        end)
    end)

    describe('mapping', function()
        local r = router.new()
        assert(r:add(all_urls))

        local cases = {
            ['/'] = {
                1, {route_name='default'}},
            ['/en/users'] = {
                2, {route_name='user_list', locale='en'}},
            ['/en/users/add'] = {
                3, {route_name='add_user', locale='en', user_id=''}},
            ['/en/user/123'] = {
                4, {route_name='user', locale='en', user_id='123'}},
            ['/de/user/123'] = {
                4, {route_name='user', locale='de', user_id='123'}},
            ['/en/user/123/groups'] = {
                5, {route_name='user_groups', locale='en', user_id='123'}},
            ['/en/user/123/group/admin'] = {
                6, {route_name='user_group', locale='en',
                    user_id='123', group='admin'}},
            ['/static/css/site.css'] = {
                10, {route_name='static', path='css/site.css'}}
        }

        describe('match', function()
            for path, m in next, cases do
                it('#1 ' .. path, function()
                    local handler, args = r:match(path)
                    assert.equals(m[1], handler)
                    assert.same(m[2], args)
                end)
            end

            it('returns nil if there is no match', function()
                assert.is_nil(r:match('/x'))
            end)
        end)

        describe('path for', function()
            for path, m in next, cases do
                it(path, function()
                    local args = m[2]
                    assert.equals(path, r:path_for(args.route_name, args))
                end)
            end

            it('raises an error if unknown name is used', function()
                assert.error(function()
                    r:path_for('x')
                end)
            end)
        end)
    end)
end)
