local cookie = require 'http.cookie'
local next, tostring = next, tostring
local describe, it, assert = describe, it, assert
_ENV = nil

describe('cookie', function()
    describe('parse', function()
        local parse = cookie.parse

        it('uses empty key if not specified', function()
            assert.same({['']=''}, parse(''))
            assert.same({['']='abc'}, parse('abc'))
        end)

        it('returns a table', function()
            assert.same({['a']='1'}, parse('a=1'))
            assert.same({a='1', b='2'}, parse('a=1; b=2'))
        end)

        it('supports values with spaces', function()
            local cases = {
                ['a b'] = 'c=a b',
                ['a '] = 'c=a ',
                [' b'] = 'c= b',
                [' '] = 'c= '
            }
            for e, s in next, cases do
                assert.equals(e, parse(s).c)
            end
        end)
    end)

    describe('dump', function()
        it('returns the serialization for use in header', function()
            local cases = {
                ['a=1'] = {name='a', value='1'},
                ['a=1; Path=/abc/'] = {name='a', value='1', path='/abc/'},
                ['a=1; Domain=x.com'] = {name='a', value='1', domain='x.com'},
                ['a=1; Expires=Mon, 09 Feb 2015 09:21:47 GMT'] = {
                    name='a', value='1', expires=1423473707
                },
                ['a=1; Max-Age=600'] = {name='a', value='1', max_age=600},
                ['a=1; HttpOnly'] = {name='a', value='1', http_only=true},
                ['a=1; Secure'] = {name='a', value='1', secure=true},
                ['a=1; Domain=x.com; Expires=Mon, 09 Feb 2015 09:21:47 GMT; '..
                 'Max-Age=600; HttpOnly; Secure'] = {
                    name='a', value='1', domain='x.com', expires=1423473707,
                    max_age=600, http_only=true, secure=true
                },
            }
            for e, c in next, cases do
                c = cookie.new(c)
                assert.equals(e, tostring(c))
                assert.equals(e, c:dump())
                assert.equals(e, cookie.dump(c))
            end
        end)
    end)
end)
