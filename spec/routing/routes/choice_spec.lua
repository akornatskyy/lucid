local choice = require 'routing.routes.choice'
local assert, describe, it, next = assert, describe, it, next
local new = choice.new

describe('choice route', function()
    local matched, args
    local path, m, a

    it('supports exact matches', function()
        local r = new('{locale:(en|ukr)}/')
        assert.same({
            ['en/'] = {locale = 'en'},
            ['ukr/'] = {locale = 'ukr'}
        }, r.exact_matches)
    end)

    describe('match', function()
        local cases = {
            ['/{locale:(en|de)}/'] = {
                {'/en/welcome', 4, {locale='en'}},
                {'/de/welcome', 4, {locale='de'}},
                {'x'}
            },
            ['{locale:(en|ukr)}/'] = {
                {'en/welcome', 3, {locale='en'}},
                {'ukr/welcome', 4, {locale='ukr'}},
                {'x'}
            }
        }
        for pattern, t in next, cases do
            local r = new(pattern)
            it(pattern, function()
                for _, c in next, t do
                    path, m, a = c[1], c[2], c[3]
                    matched, args = r:match(path)
                    assert.equals(m, matched)
                    assert.same(a, args)
                end
            end)
        end

        it('merges default args', function()
            local r = new('/{locale:(en|de)}/', nil, {site_id='1'})
            matched, args = r:match('/en/welcome')
            assert.equals(4, matched)
            assert.same({locale='en', site_id='1'}, args)
        end)
    end)
end)
