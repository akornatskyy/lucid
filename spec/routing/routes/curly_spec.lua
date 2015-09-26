local curly = require 'routing.routes.curly'
local assert, describe, it, next = assert, describe, it, next
_ENV = nil

describe('curly route', function()
    describe('convert', function()
        local convert = curly.convert
        local cases = {
            ['{id}'] = '(?P<id>[^/]+)',
            ['{id:number}'] = '(?P<id>%d+)',
            ['abc/{id:number}'] = 'abc/(?P<id>%d+)',
            ['abc/{id:i}/overview'] = 'abc/(?P<id>%d+)/overview',
            ['abc/{n1}/{n2}'] = 'abc/(?P<n1>[^/]+)/(?P<n2>[^/]+)',
            ['abc/{name:w}'] = 'abc/(?P<name>%w+)',
            ['static/{path:*}'] = 'static/(?P<path>.+)',
            ['{id:%d+}'] = '(?P<id>%d+)',
        }
        for pattern, expected in next, cases do
            it(pattern, function()
                assert.equals(expected, convert(pattern))
            end)
        end

        it('returns nil if not supported', function()
            assert.is_nil(convert('abc'))
        end)
    end)

    describe('patterns', function()
        it('have synonyms', function()
            local patterns = curly.patterns
            local map = {
                ['i'] = {'int', 'digits', 'number'},
                ['w'] = {'word'},
                ['s'] = {'segment', 'part'},
                ['a'] = {'any', 'rest', '*'}
            }
            local c = 0
            local p
            for n, syns in next, map do
                p = patterns[n]
                for _, s in next, syns do
                    assert.equals(p, patterns[s])
                    c = c + 1
                end
                c = c + 1
            end
            assert.equals(13, c)
        end)
    end)
end)
