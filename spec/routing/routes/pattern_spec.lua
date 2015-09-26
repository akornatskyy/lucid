local pattern = require 'routing.routes.pattern'
local assert, describe, it = assert, describe, it
local new = pattern.new
_ENV = nil

describe('pattern route', function()
    local r, matched, args

    it('does not support exact matches', function()
        r = new('/')
        assert.is_nil(r.exact_matches)
    end)

    describe('match', function()
        it('supports extra args', function()
            r = new('welcome', true, {locale='en'})
            matched, args = r:match('welcome')
            assert.same({locale='en'}, args)
        end)

        it('ignores extra args if captured', function()
            r = new('/(?P<locale>%l+)/welcome', true, {locale=''})
            matched, args = r:match('/en/welcome')
            assert.same({locale='en'}, args)
        end)
    end)

    describe('finishing strategy', function()
        describe('match', function()
            it('returns nil if no match found', function()
                r = new('welcome', true)
                matched = r:match('x')
                assert.is_nil(matched)
            end)

            it('supports patterns without captures', function()
                r = new('welcome', true)
                matched, args = r:match('welcome')
                assert.equals(7, matched)
                assert.same({}, args)
            end)

            it('supports single capture', function()
                r = new('user/(?P<user_id>%d+)', true)
                matched, args = r:match('user/123')
                assert.equals(8, matched)
                assert.same({user_id='123'}, args)
            end)

            it('supports multiple captures', function()
                r = new('/(?P<locale>%l%l)/user/(?P<id>%d+)/check', true)
                matched, args = r:match('/en/user/123/check')
                assert.equals(18, matched)
                assert.same({locale='en', id='123'}, args)
            end)
        end)
    end)

    describe('starts with strategy', function()
        describe('match', function()
            it('returns nil if no match found', function()
                r = new('welcome', false)
                matched = r:match('x')
                assert.is_nil(matched)
            end)

            it('supports patterns without captures', function()
                r = new('hello', false)
                matched, args = r:match('helloworld')
                assert.equals(5, matched)
                assert.same({}, args)
            end)

            it('supports single capture', function()
                r = new('user/(?P<user_id>%d+)', false)
                matched, args = r:match('user/123/check')
                assert.equals(8, matched)
                assert.same({user_id='123'}, args)
            end)

            it('supports multiple captures', function()
                r = new('/(?P<locale>%l%l)/user/(?P<id>%d+)/', false)
                matched, args = r:match('/en/user/123/check')
                assert.equals(13, matched)
                assert.same({locale='en', id='123'}, args)
            end)
        end)
    end)
end)
